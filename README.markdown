Git Push Deployer
=================

A pair of Git hooks, plus some other scripts, that let you deploy
projects using `git push`.


Branches
--------
* __master__:  tools for deploying standard, file based sites
* __database__:  utilities for managing database driven sites
* __wordpress__:  additional utilities for managing WordPress installations


To Do
-----
* Create processes for handling the `uploads` directory


Contents
--------
* `pre_deploy_script`: runs on the remote BEFORE the main files are updated
* `post_deploy_script`: runs on the remote AFTER all files have been updated
* `database-pull.sh`:  gets a database from the remote server using via SSH
* `push-with-database.sh`:  pushes the local files and database to the remote
* `database-dump.sh`:  dumps the database in a Git-friendly format
* `database-garbage-collection.php`:  removes backup copies of postings
* `database-load-prod-dump-on-local.sh`:  loads a dump and adjusts WP's URL's
* `lock.sh`:  makes files and directories read-only
* `unlock.sh`:  makes files and directories writable
* `change-url-local.php`:  sets WordPress' site URL to the local/testing value
* `change-url-prod.php`:  sets WordPress' site URL to the live/produciton value


Installation for the `wordpress` Branch
---------------------------------------

WARNING: These instructions are an experimental draft.

This is but one way to use this process.  This method permits you to
easily merge my changes into your system.  On your _remote_ server, do the
following:

	# Create your repository.
	mkdir wp
	cd wp
	git init
	git config receive.denyCurrentBranch ignore

	# Get my WordPress tools.
	git remote add -t wordpress -f git_push_deployer \
		git://github.com/convissor/git_push_deployer.git
	git pull git_push_deployer wordpress

	# Make links for the scripts so we can keep them up to date.
	ln -s ../../utilities/post-update .git/hooks/post-update
	ln -s ../../utilities/pre-receive .git/hooks/pre-receive

Then, on your local box:

	git clone ssh://<user>@<host>/<path>/wp
	cd wp

	# Rename the remote to clarify the role (and match config.sh).
	git remote rename origin prod

	# Get WordPress.
	git remote add -t 3.4-branch -f wp https://github.com/WordPress/WordPress
	git checkout -b wp34 wp/3.4-branch

	# Move WordPress into the public_html directory.
	mkdir public_html
	git mv *.html *.php *.txt public_html
	git mv wp-* public_html
	git commit -am 'Move WP files into public_html.'

	# Create your development branch.
	git checkout -b dev34

	# Bring in the Git Push Deploy utilities.
	git merge master

	# Provide the ability to get my WordPress tools locally.
	git remote add -t wordpress -f git_push_deployer \
		git://github.com/convissor/git_push_deployer.git
	git pull git_push_deployer wordpress

	# Adjust WordPress settings.
	#
	# 1) Improve your security by adding the following to wp-config.php:
	#    define('DISALLOW_UNFILTERED_HTML', true);
	# 2) On development boxes, set "WP_DEBUG" to "true" in wp-config.php.
	# 3) Change the $table_prefix.
	# 4) Update the database authentication information.
	# 5) Provide the "Unique Keys and Salts".
	#
	ln -s wp-config-sample.php public_html/wp-config.php
	git add public_html/wp-config.php
	vim public_html/wp-config.php

	# Adjust Git Push Deployer settings.
	vim auth_info.sh
	vim config.inc
	vim config.sh

	git commit -am 'My settings.'

	# Make, add, and commit any other changes you desire.
	# NOTE: Put your files in the "public_html" directory and make that
	# the document root for your web server.

	# Now hit the WordPress install on your local box in your browser.
	# Go through the installation process.
	# Activate your plugins, etc.

	# Check if there's anything that needs adding/committing.  If so, do it.
	git status
	git add --all
	git commit -am 'Other installation stuff.'

	# Now set up the production release branch.
	git checkout master
	git merge dev34

	# Set "WP_DEBUG" to "false" in wp-config.php for production.
	# And if you want to be super secure, use a lower-privileged MySQL
	# user on the production machine.
	vim public_html/wp-config.php

	git commit -m 'Production settings.' public_html/wp-config.php

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
