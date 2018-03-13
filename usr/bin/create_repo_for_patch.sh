#!/bin/bash
#
# create_repo_for_patch.sh
#
# Copyright (C) 2006 Novell Inc.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
# Free Software Foundation, Inc.,
# 51 Franklin Street,
# Fifth Floor,
# Boston, MA  02110-1301,
# USA.
#
# $Id: create_repo_for_patch.sh 182 2009-08-07 17:39:16Z lrupp $
#

MYSTART=$(pwd)
PATCHESFILE="patches.xml"
PREFIX="patch-"
DEBUG=""
SIGN_ID=""
RPMDIR="$(pwd)"
REPODIR="$(pwd)"
PREFIX="patch-"
INCSRC=""

function usage (){
    echo
    echo "Usage: $(basename $0) [options] <source directory containing RPMs> <target directory>"
    echo "       -h          : help (this message)"
    echo "       -p          : patch files (if not located in <target_directory>)"
    echo "       -P          : prefix for patchfiles (default: $PREFIX)"
    echo "       -S          : detached sign the repomd.xml file"
    echo "       -l          : set symlink to source directory"
    echo "       -s          : include source rpms"
    echo "       -I <KEY_ID> : key-id to use for signing the repomd.xml file, if not given"
    echo "                     gpg will try to use the default signing key"
    echo "       -v          : be verbose"
    echo
    echo " example: $0 -S /srv/install/ ."
    echo
    echo "WARING: $(basename $0) will delete all files except patch files in <target directory> !"
    echo
    exit $1
}

function check_binary(){
    local BINARY=$(type -p $1 2>/dev/null)
    if [ x"$BINARY" = x"" ]; then
        echo "ERROR:   $1 not found! Please install the missing package first!" >&2
        exit 3
    fi
    if [ -x "$BINARY" ]; then
        echo "$BINARY"
    else
        echo "ERROR:   $BINARY found but is not executable - please fix!" >&2
        exit 3
    fi
}


if [ ! "$1" ]; then
    usage 1
fi

while getopts 'hvSI:p:P:ls' OPTION ; do
    case $OPTION in
        h) usage 0
        ;;
        p) PATCHDIR="$OPTARG"
        ;;
        P) PREFIX="$OPTARG"
        ;;
        l) LINKRPM="1"
        ;;
        s) INCSRC="1"
        ;;
        S) SIGN="yes"
        ;;
        I) SIGN_ID="$OPTARG"
        ;;
        v) DEBUG="1"
        ;;
        *) usage 1
        ;;
    esac
done
shift $(( OPTIND - 1 ))

RPMDIR="$1"
REPODIR="$2"

CREATEREPO=$(check_binary "createrepo")
if [ $? != 0 ]; then
	exit
fi

if [ -z "$RPMDIR" ]; then
 echo "ERROR:   source directory not defined" >&2
 usage 1
fi

if [ -z "$REPODIR" ]; then
 echo "ERROR:   target directory not defined" >&2
 usage 1
fi

if [ -d "$REPODIR/repodata.tmp" ]; then
    echo "ERROR:   $REPODIR/repodata.tmp exists - exiting" >&2
    exit 1
fi       

mkdir -p "$REPODIR/repodata.tmp" || { echo "ERROR:   Cannot create ${REPODIR}/repodata.tmp"; exit 5; }

PATCHDIR=${PATCHDIR-/$RPMDIR}
echo "INFO:   --- Looking for Patches in Patchdirectory: ${PATCHDIR}"
for i in $(find "${PATCHDIR}/" -name "${PREFIX}*"); do
	[ "$DEBUG" ] && echo "INFO:    Copying patch: $i"
    cp "$i" "$REPODIR/repodata.tmp/" || { echo "ERROR: Cannot copy $i" >&2; exit 7; }
    PATCHFILES="$PATCHFILES $(basename $i)"
done

[ -d "$REPODIR/repodata" ] && rm -r "$REPODIR/repodata"
[ -d "$REPODIR/.olddata" ] && rm -r "$REPODIR/.olddata"
mkdir "$REPODIR/repodata"
 
if [ "${LINKRPM}" ]; then
	echo "INFO:   --- Linking rpms from ${RPMDIR}"
	ln -s "${RPMDIR}/rpm" ${REPODIR} || echo "WARNING: Cannot create link to ${REPODIR}" >&2
else
	echo "INFO:   --- Copying RPMs from $RPMDIR"
    [ -d "${REPODIR}/rpm" ] && rm -r $REPODIR/rpm/*
	[ "$INCSRC" ] && mkdir -p "$REPODIR/rpm/src/"
fi

for patchfile in $(ls "$REPODIR"/repodata.tmp/${PREFIX}*); do
	patch=$(basename "$patchfile")
	for rpmfile in $(grep "location href" "$patchfile"  | cut -d "\"" -f2); do
		arch_dir=$(dirname "$rpmfile" | xargs basename)
		if [ "${LINKRPM}" ]; then
			continue # do not copy files
		else
			[ -d "$REPODIR/rpm/$arch_dir" ] || mkdir -p "$REPODIR/rpm/$arch_dir"
		fi
		if [[ $rpmfile == *.delta.rpm ]]; then continue; fi
		if [[ $rpmfile == *.patch.rpm ]]; then continue; fi
		[ "$DEBUG" ] && echo "INFO:    Copying file: $RPMDIR/$rpmfile to $REPODIR/rpm/$arch_dir/"
		cp -a "$RPMDIR/$rpmfile" "$REPODIR/rpm/$arch_dir/" 2>/dev/null || { echo "ERROR:   Cannot copy $RPMDIR/$rpmfile" >&2; exit 8; }
		if ! [ "${INCSRC}" ]; then continue; fi # Include source files?
		SRCRPM=$(rpm -qp --nodigest --nosignature --qf "%{SOURCERPM}" "$RPMDIR/$rpmfile")
		[ "$DEBUG" ] && echo "INFO:    Copying file: ${RPMDIR}/rpm/src/${SRCRPM}"
		cp -a "$RPMDIR/rpm/src/$SRCRPM" "$REPODIR/rpm/src/" 2>/dev/null || echo "WARNING: Cannot copy source rpm ${RPMDIR}/rpm/src/${SRCRPM}" >&2
	done
done

#
# createrepo
#
echo "INFO:   --- Creating repodata with createrepo"
if [ "$DEBUG" ]; then
  echo "INFO:    Running command: ${CREATEREPO} -p -x "*.delta.rpm" -x "*.patch.rpm" $REPODIR"
  $CREATEREPO -p -x "*.delta.rpm" -x "*.patch.rpm" "$REPODIR" 2>/dev/null 1>&2
else
  $CREATEREPO -q -x "*.delta.rpm" -x "*.patch.rpm" "$REPODIR" 2>/dev/null 1>&2
fi

#
# patches.xml
#
echo "INFO:   --- Creating new file $REPODIR/repodata/$PATCHESFILE"
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" > "$REPODIR/repodata/$PATCHESFILE"
echo "<patches xmlns=\"http://novell.com/package/metadata/suse/patches\">" >> "$REPODIR/repodata/$PATCHESFILE"
for patch in $(ls "$REPODIR/repodata.tmp"/patch*); do
	patchname=$(basename "$patch")
    patchid=$(basename "$patchname" .xml)
    sha1=$(sha1sum "$patch" | awk '" " { print $1 }')
    mv "$REPODIR/repodata.tmp/$patchname" "$REPODIR/repodata/" || next;
	echo "  <patch id=\"$patchid\">" >> "$REPODIR/repodata/$PATCHESFILE"
	echo "    <checksum type=\"sha\">$sha1</checksum>" >> "$REPODIR/repodata/$PATCHESFILE"
    echo "    <location href=\"repodata/$patchname\"/>" >> "$REPODIR/repodata/$PATCHESFILE"
	echo "  </patch>" >> "$REPODIR/repodata/$PATCHESFILE"
done
echo "</patches>" >> "$REPODIR/repodata/$PATCHESFILE"

#
# repomd.xml
#
echo "INFO:   --- patching $REPODIR/repodata/repomd.xml"
sha1=$(sha1sum "$REPODIR/repodata/$PATCHESFILE" | awk '" " { print $1 }')
timestamp=$(date +"%Y%m%d%H")
cat >"$REPODIR/repodata.tmp/repomd.xml.patch$$" <<EOF
  <data type="patches">
    <location href="repodata/patches.xml"/>
    <checksum type="sha">$sha1</checksum>
    <timestamp>$timestamp</timestamp>
    <open-checksum type="sha">$sha1</open-checksum>
  </data>
</repomd>
EOF
sed -i '/.*<\/repomd>.*/d' "$REPODIR/repodata/repomd.xml" || { echo 'ERROR: sed command failed!' >&2; exit 9; }
cat "$REPODIR/repodata.tmp/repomd.xml.patch$$" >> "$REPODIR/repodata/repomd.xml"
rm -r "$REPODIR/repodata.tmp"

#
# repomd.xml.key
#
if [ "$SIGN" == "yes" ]; then
	echo "INFO:   --- Signing repomd.xml"
    if [ "${SIGN_ID}" = "" ]; then
		if [ -f "/etc/sign.conf" ]; then
			[ "$DEBUG" ] && echo "INFO:   Try to sign with key from /etc/sign.conf"
			if [ -x $(type -p sign) ]; then
				$(type -p sign) -d "$REPODIR/repodata/repomd.xml"
			else
				echo "ERROR:  Could not execute 'sign'" >&2
				exit 1;
			fi
		else
        	gpg -a -b "${REPODIR}/repodata/repomd.xml"
		fi
       	SIGN_ID=$(gpg --verify "${REPODIR}/repodata/repomd.xml.asc" 2>&1 | sed -ne "s/.* ID //p")
    else
        gpg -a -b --default-key ${SIGN_ID} "${REPODIR}/repodata/repomd.xml"
    fi
    echo "INFO:    with Key-ID: ${SIGN_ID}"
    gpg -a --export ${SIGN_ID} > "${REPODIR}/repodata/repomd.xml.key"
fi
