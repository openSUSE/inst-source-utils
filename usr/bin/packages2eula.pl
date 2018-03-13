#! /usr/bin/perl -w
#
# packages2eula.pl -- generates a concatenated EULA.txt from a packages file
#
# (C) 2007, jw@suse.de, Novell Inc.
# Distributable under GPLv2 or GPLv3.
#
# This implements https://keeper.suse.de/webfate/match/id?value=302018
#
# $Id: packages2eula.pl,v 1.4 2007/08/06 17:35:36 jw Exp jw $
# $Log: packages2eula.pl,v $
# Revision 1.4  2007/08/06 17:35:36  jw
# do not modify EULA.txt if no licenses found. (did append = = END = =) before.
#
# Revision 1.3  2007/08/06 17:34:57  jw
# *** empty log message ***
#
# Revision 1.2  2007/08/06 17:34:02  jw
# *** empty log message ***
#
# Revision 1.1  2007/06/05 12:24:39  root
# Initial revision
#

use Data::Dumper;

my $version = '1.1';
my $verbose = 1;
my $in_file;
my $out_file;
my $packages_file_def = 'suse/setup/descr/packages.en';
my $packages_file;
my $with_content = 1;
my $with_listing = 1;
my $translation_archive = "/media.1/licenses.zip";

while (defined (my $arg = shift))
  {
    if    ($arg !~ m{^-.})              { unshift @ARGV, $arg; last }
    elsif ($arg =~ m{^(-h|--help|-\?)}) { exit usage(); }
    elsif ($arg =~ m{^--?v})            { $verbose++; }
    elsif ($arg =~ m{^--?q})            { $verbose = 0; }
    elsif ($arg =~ m{^--?i})            { $in_file = shift; }
    elsif ($arg =~ m{^--?o})            { $out_file = shift; }
    elsif ($arg =~ m{^--?p})            { $packages_file = shift; }
    elsif ($arg =~ m{^--?c})		{ $with_content = !$with_content; }
    elsif ($arg =~ m{^--?l})		{ $with_listing = !$with_listing; }
    else { exit usage("unknown option $arg"); }
  }

$out_file ||= '-';
$in_file = $out_file if !$in_file and $out_file ne '-';
$out_file = $in_file if $out_file eq '=';
unless (defined $packages_file)
  {
    $packages_file = $packages_file_def; 	#  default from current dir.
    
    unless (-f $packages_file)			# try relative to $in_file
      {
        ($packages_file = ($in_file||'')) =~ s{[^/]+$}{};
        $packages_file .= $packages_file_def;
      }
    
    unless (-f $packages_file)			# try relative to $out_file
      {
        ($packages_file = ($out_file||'')) =~ s{[^/]+$}{};
        $packages_file .= $packages_file_def;
      }
  }

exit usage("need at least one of -i or -o\n") unless $in_file and $out_file;

print "using packages_file: $packages_file\n" if $verbose;
open P, "<", $packages_file or die "cannot read $packages_file: $!\n";

my $pkg;
my %eul;
my $name = '';
while (defined(my $line = <P>))
  {
    chomp $line;
    next if $line =~ m{^#};
    if ($line =~ m{^([+=])(\w+):\s*(.*)$})
      {
        my ($sign, $key, $val) = ($1,$2,$3);
	if ($sign eq '+')
	  {
	    while (defined($line = <P>))
	      {
	        last if $line =~ m{^\-$key:\s*$};
	        $val .= $line;
	      }
	  }
	if ($key eq 'Pkg')
	  {
	    $val =~ s{\s+$}{};
	    my @n = split /\s+/, $val;
	    $name = "$n[0]-$n[1]-$n[2]";
	    $pkg->{$name}{name} = $n[0];
	    $pkg->{$name}{version} = $n[1];
	    $pkg->{$name}{release} = $n[2];
	    $pkg->{$name}{arch} = $n[3];
	  }
	elsif ($key =~ m{(Eul|Sum)})
	  {
	    next unless $name;	# packages.en starts with "=Ver: 2.0"

	    $pkg->{$name}{$key} = decode_richtext($val);
	    push @{$eul{$pkg->{$name}{$key}}{pkg}}, $name if $key eq 'Eul';
	  }
        # ignore all other keys.
      }
  }
close P;

# find license titles
for my $e (keys %eul)
  {
    my $head = '';
    while ($e =~ m{^(.*)$}mg)
      {
        my $h = $1;
	$h =~ s{^\s+}{};
	$h =~ s{\s+$}{};
	next unless length $h;

	$head .= "\n$h";
	last if good_title($head);
      }
    $eul{$e}{head} = $head;
    $eul{$e}{body} = $e;
  }

# sort by title
my @eul = sort { lc $a->{head} cmp lc $b->{head} } values %eul;
undef %eul;

for my $i (0..$#eul)
  {
    $eul[$i]{app} = sprintf "APPENDIX_%d", $i+1;
    $eul[$i]{lst} = $with_listing ? "(" . join(' ', sort @{$eul[$i]{pkg}}) . ")\n\t" : "";
  }

# preload the $in_file, in case in_file and out_file are identical.
open IN, "<", $in_file or die "$0: failed to read $in_file: $!\n";
my $novell_eula = join '', <IN>;
close IN;
if ($novell_eula =~ m{= = = = = = = = = \s+Content:\n.*\s+APPENDIX_\d\n}s and
    $novell_eula =~ m{= = = = = = = = = END( =)+\s*$}s)
  {
    warn "\nWARNING: Looks like Appendices are already present in $in_file.\n\n";
    exit 0;
  }

open OUT, ">$out_file" or die "$0: failed to open $out_file: $!\n";

# 1) copy input EULA text verbatim.
print OUT $novell_eula;

# 2) append a content listing, if desired
if ($with_content and scalar @eul)
  {
    print OUT "\n".("= " x 33)."\n";
    print OUT "\nContent:\n";
    for my $e (@eul)
      {
        print OUT "$e->{head}\n\t$e->{lst} See $e->{app}\n";
      }
    print OUT "\n";
  }

# 3) append each EULA with a separtion line containing AppendixN
# so that we can jump directly.
for my $e (@eul)
  {
    print OUT "\n".("= " x 14).$e->{app}.(" =" x 13)."\n$e->{lst}\n";
    print OUT $e->{body};
  }

print OUT "\n".("= " x 16)."END".(" =" x 15)."\n" if scalar @eul;
close OUT or die "could not write $out_file: $!\n";

printf STDERR "%d Appendices written.\n", scalar @eul if $verbose;

exit 0;
############################################################

# get EULA header: first line, plus second text line
# if the word 'license' oder 'agreement' are not in first.
# but only 'End User License Agreement' is insufficient.
sub good_title
{
  my ($text) = @_;
  return 0 unless $text =~ m{(license|licence|agreement)}i;
  $text =~ s{(license|licence|agreement|end|user)}{}gi;
  return 0 if $text =~ m{^\s*$}s;
  return 1;
}

sub decode_richtext
{
  my ($txt) = @_;
  return $txt unless $txt =~ s{^\Q<!-- DT:Rich -->\E}{};
  $txt =~ s{<p>\s*}{\n}g;
  $txt =~ s{</p>\s*}{\n}g;
  $txt =~ s{&quot;}{"}g;
  $txt =~ s{&#39;}{'}g;
  $txt =~ s{<ol>\s*}{\n}g;
  $txt =~ s{<li>\s*}{ * }g;
  $txt =~ s{</li>\s*}{}g;
  $txt =~ s{</ol>\s*}{\n}g;

  $txt =~ s{</\w+>\s*}{}g;
  $txt =~ s{^\s+}{}g;
  $txt =~ s{\s+$}{}g;
  return $txt;
}

sub usage
{
  my ($msg) = @_;
  print STDERR qq{$0 V$version usage:

encoding [options] [file]

valid options are:
 -h                         Print this online help
 -v                         Be more verbose. Default $verbose
 -q                         Be quiet
 -i inputEULA.txt           Defaults to the same name as given with -o
 -o outputEULA.txt          Defaults to stdout, if also -i is given.
 			    Use -o = for inplace modification.
 -p packages_file           Defaults to '$packages_file_def'; tested also relative 
                            to -i and -o argument.
 -c                         Toggle writing of a content table. 
                            Default: $with_content.
 -l                         Toggle writing of package listing corresponding
                            to the added EULAs.  Default: $with_listing.
};
  print STDERR "\nERROR: $msg\n" if $msg;
  return 0;
}

