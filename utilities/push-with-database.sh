#! /bin/bash

if [[ $1 == "-h" || $1 == "--help" || $1 == "help" ]] ; then
	echo "Usage:  ./push-with-database.sh [remote] [disable_logins]"
	echo "  @param string remote  Git remote to pull the database from."
	echo "                        Defaults to \$git_remote_prod in config.sh."
	echo "  @param int disable_logins  should WordPress logins on the remote"
	echo "                             server be disabled?  1 = yes, 0 = no,"
	echo "                             - = no action.  Default: script asks."
	echo "                             Only applies if the Login Security"
	echo "                             Solution plugin is installed."
	echo ""
	echo "Deploys your local database and the files in your local production"
	echo "branch to the Git remote specified."
	echo ""
	echo "NOTE: our pre-recieve and post-update hook scripts MUST be installed"
	echo "on the remote server for this deployment process to work."
	echo ""
	echo "Author: Daniel Convissor <danielc@analysisandsolutions.com>"
	echo "License: http://www.analysisandsolutions.com/software/license.htm"
	echo "Link: https://github.com/convissor/git_push_deployer"
	exit 1
fi


remote=$1
disable_logins=$2

dir_util="$(cd "$(dirname "$0")" && pwd)"
source "$dir_util/config.sh"

remote=${remote:-$git_remote_prod}
result=`git remote show -n "$remote" | grep 'Fetch URL: ssh://'`
if [ $? -ne 0 ] ; then
	echo "ERROR: '$remote' is an unknown remote or isn't using SSH."
	exit 1
fi
dir_remote=`echo "$result" | sed -E 's@^.+ssh://[^/]+(.*)$@\1@'`

# Bail on errors from here on out.
set -e

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

echo "About to do the following:"
echo "* git checkout $git_branch_dev"
echo "* database-dump.sh"
echo "* git checkout $git_branch_prod"
echo "* git cherry-pick <database dump commit id>"
echo "* git push $remote $git_branch_prod"
echo "* git checkout $git_branch_dev"
echo ""
echo "To change the remote, pass it in on the command line."
echo "To change branch names, edit config.sh."
echo ""
echo -n "Hit ENTER to proceed or CTRL-C to cancel..."
read -e

git checkout "$git_branch_dev"

php "$dir_util/database-garbage-collection.php"
php "$dir_util/change-url-prod.php"

"$dir_util/database-dump.sh" "$file_sql_dump"
git add --ignore-errors "$file_sql_dump"
git commit -m 'Latest local database.' "$file_sql_dump"
id=`git log -n 1 --pretty=format:%H`

php "$dir_util/change-url-local.php"

git checkout "$git_branch_prod"
git cherry-pick "$id"

touch "$file_sql_push_flag"
git add "$file_sql_push_flag"
git commit -m 'Add database push flag.' "$file_sql_push_flag"

if [ -n "$disable_logins" ] ; then
	remote_file_disable_login="$dir_remote/${file_disable_login:${#dir_base}+1:${#file_disable_login}}"
	echo "php '$remote_file_disable_login' $disable_logins" > "$file_actions_post"
	git add "$file_actions_post"
	git commit -m 'Add post action script.' "$file_actions_post"
fi

git push "$remote" "$git_branch_prod"

git rm "$file_sql_push_flag"
git commit -m 'Remove database push flag.' "$file_sql_push_flag"

if [ -n "$disable_logins" ] ; then
	git rm "$file_actions_post"
	git commit -m 'Remove post action script.' "$file_actions_post"
fi

git checkout "$git_branch_dev"
