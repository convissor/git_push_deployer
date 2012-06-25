#! /bin/bash -e

if [[ $1 == "-h" || $1 == "--help" || $1 == "help" ]] ; then
	echo "Usage:  ./database-dump.sh [filename]"
	echo "  @param string filename  the file name where the database dump"
	echo "         will be saved.  Default: database-dump.sql"
	echo ""
	echo "Dumps this website's database, formatted for version control."
	echo ""
	echo "Author: Daniel Convissor <danielc@analysisandsolutions.com>"
	echo "License: http://www.analysisandsolutions.com/software/license.htm"
	echo "Link: https://github.com/convissor/git_push_deployer"
	exit 1
fi


dir_util="$(cd "$(dirname "$0")" && pwd)"
source "$dir_util/config.sh"
source "$dir_util/auth_info.sh"

if [ -z "$1" ] ; then
	file=$file_sql_dump
else
	file=$1
fi

# Make life easier on the receiving end.
echo "DROP DATABASE IF EXISTS \`$db_name\`;" > "$file"
echo "CREATE DATABASE \`$db_name\`;" >> "$file"
echo "USE \`$db_name\`;" >> "$file"

# Leave off "--lock-tables" if you want unprivileged user to run this.
mysqldump --skip-opt --add-locks --lock-tables --create-options \
	--quick --set-charset --disable-keys \
	-u "$db_user" --password="$db_password" "$db_name" >> "$file"
