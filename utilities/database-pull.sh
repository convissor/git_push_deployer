#! /bin/bash

if [[ -z $1 || $1 == "-h" || $1 == "--help" || $1 == "help" ]] ; then
	echo "Usage:  ./database-pull.sh dest [remote]"
	echo "  @param string dest  where to put the database dump."
	echo "                      '-' copies directly to the local database."
	echo "                      Names ending in '.bz2' get bzip2 compressed."
	echo "  @param string remote  Git remote to pull the database from."
	echo "                        Defaults to \$git_remote_prod in config.sh."
	echo ""
	echo "Copies a database from a remote server to this server, using SSH."
	echo ""
	echo "Author: Daniel Convissor <danielc@analysisandsolutions.com>"
	echo "License: http://www.analysisandsolutions.com/software/license.htm"
	echo "Link: https://github.com/convissor/git_push_deployer"
	exit 1
fi


dest=$1
remote=$2

dir_util="$(cd "$(dirname "$0")" && pwd)"
source "$dir_util/config.sh"

remote=${remote:-$git_remote_prod}
result=`git remote show -n "$remote" | grep 'Fetch URL: ssh://'`
if [ $? -ne 0 ] ; then
	echo "ERROR: '$remote' is an unknown remote or isn't using SSH."
	exit 1
fi

# Bail on errors from here on out.
set -e

user_host=`echo "$result" | sed -E 's@^.+ssh://([^/]+).*$@\1@'`
dir_remote=`echo "$result" | sed -E 's@^.+ssh://[^/]+(.*)$@\1@'`
cmd="ssh $user_host '$dir_remote/$dir_util_name/help-database-pull.sh'"

# Note: the remote helper script compresses the stream before sending it.
if [ "$dest" = "-" ] ; then
	$cmd | "$dir_util/database-load-prod-dump-on-local.sh" -
elif [[ "${dest:${#dest}-4}" = ".bz2" ]] ; then
	$cmd > "$dest"
else
	$cmd | bzip2 -dc > "$dest"
fi
