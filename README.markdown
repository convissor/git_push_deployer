Git Push Deployer
=================

A pair of Git hooks, plus some other scripts, that let you deploy
projects using `git push`.


Branches
--------
* __master__:  tools for deploying standard, file based sites
* __database__:  utilities for managing database driven sites
* __wordpress__:  additional utilities for managing WordPress installations


Contents
--------
* `pre_deploy_script`: runs on the remote BEFORE the main files are updated
* `post_deploy_script`: runs on the remote AFTER all files have been updated
* `database-pull.sh`:  gets a database from the remote server using via SSH
* `push-with-database.sh`:  pushes the local files and database to the remote
* `database-dump.sh`:  dumps the database in a Git-friendly format
* `database-load-prod-dump-on-local.sh`:  loads a dump and adjusts WP's URL's
* `lock.sh`:  makes files and directories read-only
* `unlock.sh`:  makes files and directories writable


Installation for the `database` Branch
--------------------------------------

WARNING: These instructions are an experimental draft.

This is but one way to use this process.  This method permits you to
easily merge my changes into your system.  On your _remote_ server, do the
following:

	# Create your repository.
	mkdir <project>
	cd <project>
	git init
	git config receive.denyCurrentBranch ignore

	# Get my WordPress tools.
	git remote add -t database git_push_deployer \
		git://github.com/convissor/git_push_deployer.git
	git pull git_push_deployer database

	# Make links for the scripts so we can keep them up to date.
	ln -s ../../utilities/post-update .git/hooks/post-update
	ln -s ../../utilities/pre-receive .git/hooks/pre-receive

Then, on your local box:

	git clone ssh://<user>@<host>/<path>/<project>
	cd <project>

	# Rename the remote to clarify the role (and match config.sh).
	git remote rename origin prod

	# Create your development branch.
	git checkout -b dev

	# Provide the ability to get my WordPress tools locally.
	git remote add -t database -f git_push_deployer \
		git://github.com/convissor/git_push_deployer.git
	git pull git_push_deployer database

	# Adjust Git Push Deployer settings.
	vim auth_info.sh
	vim config.inc
	vim config.sh

	git commit -am 'My settings.'

	# Make, add, and commit any other changes you desire.
	# NOTE: Put your files in the public_html directory and make that
	# the document root for your web server.

	# Bring changes into the production release branch.
	git checkout master
	git merge dev

	# Now push the database and files up to production.
	./utilities/push-with-database.sh

	# In the future, if you just want to push files, do this
	# (after merging changes into master from the development branch).
	git push prod master


Inspiration
-----------
This project was inspired by http://utsl.gen.nz/git/post-update.
Restructuring it to include a pre-receive script permits using the system
with repositories that don't have any commits and utilize files in the
"utilities" directory without running into the following errors:
* `fatal: bad revision 'HEAD'`
* `warning: Log .git/logs/HEAD has gap after`
* `warning: Log for 'HEAD' only has 1 entries.`
* `fatal: ambiguous argument 'HEAD@{1}': unknown revision or path not in the working tree.`
