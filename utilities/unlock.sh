#! /bin/bash -e

if [[ $1 == "-h" || $1 == "--help" || $1 == "help" ]] ; then
	echo "Usage:  ./unlock.sh"
	echo ""
	echo "Makes files and directories writable."
	echo ""
	echo "Author: Daniel Convissor <danielc@analysisandsolutions.com>"
	echo "License: http://www.analysisandsolutions.com/software/license.htm"
	echo "Link: https://github.com/convissor/git_push_deployer"
	exit 1
fi


dir_util="$(cd "$(dirname "$0")" && pwd)"
source "$dir_util/config.sh"

echo "> >  Unlocking file system..."

find "$dir_doc_root" -type d \
	-exec chmod 2770 {} \;
find "$dir_doc_root" -type f -not -name \*.sh \
	-exec chmod 660 {} \;
find "$dir_doc_root" -type f -name \*.sh \
	-exec chmod 770 {} \;

echo "> >  File system UNLOCKED."
