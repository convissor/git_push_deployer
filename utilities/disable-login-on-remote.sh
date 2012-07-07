#! /bin/bash

if [[ $1 != 0 && $1 != 1 ]] ; then
	echo "Usage:  ./disable-login-on-remote.sh dest <disable_logins> [remote]"
	echo "  @param int disable_logins  should WordPress logins on the remote"
	echo "                             server be disabled?  1 = yes, 0 = no."
	echo "  @param string remote  Git remote to pull the database from."
	echo "                        Defaults to \$git_remote_prod in config.sh."
	echo ""
	echo "NOTE: reqiures the Login Security Solution plugin for WordPress."
	echo ""
	echo "Author: Daniel Convissor <danielc@analysisandsolutions.com>"
	echo "License: http://www.analysisandsolutions.com/software/license.htm"
	echo "Link: https://github.com/convissor/git_push_deployer"
	exit 1
fi


disable_logins=$1
remote=$2

dir_util="$(cd "$(dirname "$0")" && pwd)"
source "$dir_util/config.sh"

if [ ! -f "$file_disable_login" ] ; then
	echo "ERROR: could't find the Login Security Solution plugin."
	exit 1
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
remote_file_disable_login="$dir_remote/${file_disable_login:${#dir_base}+1:${#file_disable_login}}"

ssh $user_host "php '$remote_file_disable_login'" $disable_logins
