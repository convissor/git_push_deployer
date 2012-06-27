#! /bin/bash -e

if [[ -z $1 || $1 == "-h" || $1 == "--help" || $1 == "help" ]] ; then
	echo "Usage:  ./database-load-prod-dump-on-local.sh src"
	echo "  @param string src  the database dump file to import."
	echo "                     Files ending in '.bz2' can be used."
	echo "                     '-' means use the bzip2 compressed STDIN."
	echo ""
	echo "Takes an existing database dump file from the live server and"
	echo "pushes it into the local database instance."
	echo ""
	echo "Author: Daniel Convissor <danielc@analysisandsolutions.com>"
	echo "License: http://www.analysisandsolutions.com/software/license.htm"
	echo "Link: https://github.com/convissor/git_push_deployer"
	exit 1
fi


src=$1

dir_util="$(cd "$(dirname "$0")" && pwd)"
source "$dir_util/config.sh"
source "$dir_util/auth_info.sh"

if [ "$src" = "-" ] ; then
	bzip2 -dc | mysql -u "$db_user" --password="$db_password" "$db_name"
elif [ -f "$src" ] ; then
	if [[ "${src:${#src}-4}" = ".bz2" ]] ; then
		bzip2 -dc "$src" | \
			mysql -u "$db_user" --password="$db_password" "$db_name"
	else
		mysql -u "$db_user" --password="$db_password" "$db_name" < "$src"
	fi
else
	echo "ERROR: '$src' does not exist."
	exit 1
fi
