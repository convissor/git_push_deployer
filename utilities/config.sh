# Your local development branch.
git_branch_dev=dev34

# Your production release remote and branch.
git_remote_prod=prod
git_branch_prod=master

# WordPress' active remote and release branch.
git_remote_origin_url=https://github.com/WordPress/WordPress
git_remote_origin=wp
# The remote branch name that holds WP's release branch.
git_branch_origin=3.4-branch
# The local branch name for holding WP's release branch.
git_branch_dev_merge=wp34


# You probably shouldn't touch the settings below here.

if [ -z "$dir_util" ] ; then
	dir_util="$(cd "$(dirname "$0")" && pwd)"
fi
dir_util_name=`basename "$dir_util"`
dir_base=`dirname "$dir_util"`
dir_doc_root="$dir_base/public_html"
dir_uploads="$dir_doc_root/wp-content/uploads"
dir_backups="$dir_base/backups"

file_sql_dump="$dir_util/database-dump.sql"
file_sql_push_flag="$dir_util/database-push-flag"
file_actions_post="$dir_util/actions-post-deploy"
file_disable_login="$dir_doc_root/wp-content/plugins/login-security-solution/utilities/disable_logins_setter.php"

site=`basename "$dir_base"`
date=`date +%Y-%m-%d_%H-%M-%S`
