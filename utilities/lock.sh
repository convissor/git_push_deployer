#! /bin/bash -e

if [[ $1 == "-h" || $1 == "--help" || $1 == "help" ]] ; then
	echo "Usage:  ./lock.sh"
	echo ""
	echo "Makes files and directories read-only."
	echo ""
	echo "Author: Daniel Convissor <danielc@analysisandsolutions.com>"
	echo "License: http://www.analysisandsolutions.com/software/license.htm"
	echo "Link: https://github.com/convissor/git_push_deployer"
	exit 1
fi


dir_util="$(cd "$(dirname "$0")" && pwd)"
source "$dir_util/config.sh"

echo "> >  Locking file system..."

find "$dir_doc_root" -type d \
	-exec chmod 2550 {} \;
find "$dir_doc_root" -type f -not -name \*.sh \
	-exec chmod 440 {} \;
find "$dir_doc_root" -type f -name \*.sh \
	-exec chmod 550 {} \;

echo "> >  File system LOCKED."
