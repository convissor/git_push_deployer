#! /bin/bash -e

if [[ $1 == "-h" || $1 == "--help" || $1 == "help" ]] ; then
	echo "Usage:  ./help-database-pull.sh [disable_logins]"
	echo "  @param int disable_logins  should WordPress logins on the remote"
	echo "                             server be disabled?  1 = yes, 0 = no."
	echo "                             Default: no action.  Only applies if"
	echo "                             the Login Security Solution plugin"
	echo "                             is installed."
	echo ""
	echo "The database-pull.sh script executes this on the server."
	echo "This sends the bzip2 compressed database dump to STDOUT."
	echo ""
	echo "Author: Daniel Convissor <danielc@analysisandsolutions.com>"
	echo "License: http://www.analysisandsolutions.com/software/license.htm"
	echo "Link: https://github.com/convissor/git_push_deployer"
	exit 1
fi


disable_logins=$1

dir_util="$(cd "$(dirname "$0")" && pwd)"
source "$dir_util/config.sh"

file=`mktemp`
trap "rm -f '$file'; exit" INT TERM EXIT

"$dir_util/database-dump.sh" "$file"

# Cat avoids bzip2 saying "I won't write compressed data to a terminal."
bzip2 -zc "$file" | cat

if [ -f "$file_disable_login" ] ; then
	if [[ $disable_logins -eq 0 || $disable_logins -eq 1 ]] ; then
		php "$file_disable_login" $disable_logins
	fi
fi
