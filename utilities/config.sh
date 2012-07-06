# Your local development branch.
git_branch_dev=dev

# Your production release remote and branch.
git_remote_prod=prod
git_branch_prod=master


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

site=`basename "$dir_base"`
date=`date +%Y-%m-%d_%H-%M-%S`
