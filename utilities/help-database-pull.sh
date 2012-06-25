#! /bin/bash -e

if [[ $1 == "-h" || $1 == "--help" || $1 == "help" ]] ; then
	echo "Usage:  ./help-database-pull.sh"
	echo ""
	echo "The database-pull.sh script executes this on the server."
	echo "This sends the bzip2 compressed database dump to STDOUT."
	echo ""
	echo "Author: Daniel Convissor <danielc@analysisandsolutions.com>"
	echo "License: http://www.analysisandsolutions.com/software/license.htm"
	echo "Link: https://github.com/convissor/git_push_deployer"
	exit 1
fi


dir_util="$(cd "$(dirname "$0")" && pwd)"
source "$dir_util/config.sh"

file=`mktemp`
trap "rm -f '$file'; exit" INT TERM EXIT

"$dir_util/database-dump.sh" "$file"

# Cat avoids bzip2 saying "I won't write compressed data to a terminal."
bzip2 -zc "$file" | cat
