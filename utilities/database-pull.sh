#! /bin/bash

if [[ -z $1 || $1 == "-h" || $1 == "--help" || $1 == "help" ]] ; then
	echo "Usage:  ./database-pull.sh dest [remote] [disable_logins]"
	echo "  @param string dest  where to put the database dump."
	echo "                      '-' copies directly to the local database."
	echo "                      Names ending in '.bz2' get bzip2 compressed."
	echo "  @param string remote  Git remote to pull the database from."
	echo "                        Defaults to \$git_remote_prod in config.sh."
	echo "  @param int disable_logins  should WordPress logins on the remote"
	echo "                             server be disabled?  1 = yes, 0 = no,"
	echo "                             - = no action.  Default: script asks."
	echo "                             Only applies if the Login Security"
	echo "                             Solution plugin is installed."
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
disable_logins=$3

dir_util="$(cd "$(dirname "$0")" && pwd)"
source "$dir_util/config.sh"

if [ -f "$file_disable_login" ] ; then
	if [ -z "$disable_logins" ] ; then
		echo "Should WordPress logins be disabled on the remote server?"
		echo -n "default = don't change, 1 = disable logins, 0 = enable logins: "
		read disable_logins
	fi

	if [ "$disable_logins" = "-" ] ; then
		disable_logins=
	fi

	if [[ -n "$disable_logins" && "$disable_logins" != 0 && "$disable_logins" != 1 ]] ; then
		echo "ERROR: answer must be empty, 0 or 1."
		exit 1
	fi
fi

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
cmd="ssh $user_host '$dir_remote$dir_util_name/help-database-pull.sh' $disable_logins"

# Note: the remote helper script compresses the stream before sending it.
if [ "$dest" = "-" ] ; then
	$cmd | "$dir_util/database-load-prod-dump-on-local.sh" -
elif [[ "${dest:${#dest}-4}" = ".bz2" ]] ; then
	$cmd > "$dest"
else
	$cmd | bzip2 -dc > "$dest"
fi
