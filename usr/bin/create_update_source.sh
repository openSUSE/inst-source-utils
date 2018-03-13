#!/bin/sh
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
# This script creates an additional source in an existing tree to accomodate
# update packages without changing the original product tree.
# The script will only create the directory structure and the needed meta files.
#
# After running this script, you have to copy the packages into 
#
#		<source>/updates/suse/<arch>
#
# and run the script 
#
#	 	/usr/bin/create_package_descr -x setup/descr/EXTRA_PROV \
#
# in the data directory (<source>/updates/suse)
# after that do "cd setup/descr" and then:
# for i in *; do echo -n "META SHA1 "; sha1sum $i|awk '{ORS=""; print $1}'; echo -n " "; basename $i; done
# copy the output to the end of the updates/content file
#
#
# Anas Nashif
# Uwe Gansert (uwe.gansert@suse.de)
#
# Version 20060925 (uwe.gansert@suse.de)
#   - replaced =~ by grep to be compatible to pre bash 3.0
#
# Version 20060420 (uwe.gansert@suse.de)
#   - suppress META SHA1 lines in the content file
#
# Version 20060418 (uwe.gansert@suse.de)
#   - added support for add-on products of SLES10/SL10.1
#
# Version 20051207 (uwe.gansert@suse.de)
#   - added missing $SOURCE for the copy of the EXTRA_PROV file
#     thanx to Ian Grant
#

SOURCE=$1
ECHO=""
UPDATES="$SOURCE/updates"
NAME="Updates"

tmpcontent=`mktemp  /var/tmp/content-XXXXXX`

if [ -z "$SOURCE" ]; then
	echo
	echo "Argument missing, Provide the root of the installation source as"
	echo "the first argument"
	echo
	exit 1
fi

echo "Creating $UPDATES.."
if test -d $UPDATES ; then
	echo
	echo "$UPDATES already exists, aborting";
	echo
	exit 1
fi

function create_dy() {

	test -d $1 || return;

	for i in `ls $1` ; do
		case $i in
			*directory.yast)
			continue
		;;
		esac
		if test -d "$1/$i" ; then
			echo "$i/"
		else
			echo "$i"
		fi
	done > $1/directory.yast
}




if [ -f $SOURCE/content ] ; then
   while read KEY VALUE ; do
        case $KEY in
                DATADIR)
                        DATADIR=$VALUE
						echo $KEY $VALUE
                        ;;
                PRODUCT)
						echo $KEY $VALUE $NAME
                        ;;
                DESCRDIR)
                        DESCRDIR=$VALUE
						echo $KEY $VALUE
                        ;;
                DISTPRODUCT)
                        DISTPRODUCT=$VALUE
						echo "$KEY SuSE-Linux-Updates"
                        ;;
                DISTVERSION)
                        DISTVERSION=$VALUE
                        ;;
                META)
                        if [ -z "`echo -n $VALUE | grep SHA1`" ]; then
                            echo $KEY $VALUE
                        fi;
                        ;;
                ARCH.*)
                        if test -z "$ARCH"; then 
							ARCH=$VALUE
						fi
						echo $KEY $VALUE
                        ;;
				*)
						echo $KEY $VALUE
        esac
   done < $SOURCE/content > $tmpcontent


   DISTVERSION=`echo $DISTVERSION | tr '-' '#'`
   DISTIDENT="$DISTPRODUCT-$DISTVERSION"
   for i in $SOURCE/media.? ; do
      test -d $i || continue
      {
        read VENDOR
        read CREATIONDATE
      } < $i/media
   done
fi


$ECHO mkdir -p $UPDATES/$DATADIR
$ECHO mkdir -p $UPDATES/media.1
for arch in $ARCH; do 
	$ECHO mkdir -p $UPDATES/$DATADIR/$arch
done

$ECHO mkdir -p $UPDATES/$DESCRDIR

if [ -f "$SOURCE/$DESCRDIR/EXTRA_PROV" ]; then
	$ECHO cp $SOURCE/$DESCRDIR/EXTRA_PROV $UPDATES/$DESCRDIR
else
	echo "$DESCRDIR/EXTRA_PROV not found, trying to find it elsewhere..."
	find -name  EXTRA_PROV -exec cp {} $UPDATES/$DESCRDIR \;
fi


$ECHO mkdir -p $UPDATES/media.1
{
	echo "SuSE Linux AG"
	date +%Y%m%d%H%M%S
	echo 1
} > $UPDATES/media.1/media

{
    echo "/ $DISTPRODUCT-$NAME"
} > $UPDATES/media.1/products

if [ -x /usr/bin/create_package_descr ]; then
	create_package_descr -x $UPDATES/$DESCRDIR/EXTRA_PROV -d $UPDATES/$DATADIR \
					-o $UPDATES/$DESCRDIR
fi

(
	cd $UPDATES
        create_dy .
	for j in boot boot/loader $DESCRDIR media.1 ; do
    	create_dy $j
	done
	if [ -d $DESCRDIR/../slide ] ; then
    	for j in `find $DESCRDIR/../slide -type d ` ; do
        	create_dy $j
    	done
	fi
)


mkdir -p $SOURCE/yast


updates=`basename $UPDATES`
if [ -f "$SOURCE/yast/order" ]; then
	if grep -q $updates $SOURCE/yast/order ; then
		echo
		echo "order/instorder already in place, not touching them"
		echo
	else
		CREATE_ORDER=1
	fi
else
	CREATE_ORDER=1
fi


if [ "$CREATE_ORDER" = 1 ]; then
	echo "/$updates /$updates" >> $SOURCE/yast/order
	echo "/" >> $SOURCE/yast/order
	echo "/$updates" >> $SOURCE/yast/instorder
	echo  "/" >> $SOURCE/yast/instorder
fi


cp $tmpcontent $UPDATES/content
chmod a+r $UPDATES/content
rm -f $tmpcontent



