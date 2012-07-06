#! /bin/bash

if [[ $1 == "-h" || $1 == "--help" || $1 == "help" ]] ; then
	echo "Usage:  ./push-with-database.sh [remote]"
	echo "  @param string remote  Git remote to pull the database from."
	echo "                        Defaults to \$git_remote_prod in config.sh."
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

"$dir_util/database-dump.sh" "$file_sql_dump"
git add --ignore-errors "$file_sql_dump"
git commit -m 'Latest local database.' "$file_sql_dump"
id=`git log -n 1 --pretty=format:%H`

git checkout "$git_branch_prod"
git cherry-pick "$id"

touch "$file_sql_push_flag"
git add "$file_sql_push_flag"
git commit -m 'Add database push flag.' "$file_sql_push_flag"

git push "$remote" "$git_branch_prod"

git rm "$file_sql_push_flag"
git commit -m 'Remove database push flag.' "$file_sql_push_flag"

git checkout "$git_branch_dev"
