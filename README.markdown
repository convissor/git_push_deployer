Git Push Deployer
=================

A pair of Git hooks, plus some other scripts, that let you deploy
projects using `git push`.


Branches
--------
* __master__:  tools for deploying standard, file based sites
* __wordpress__:  additional utilities for managing WordPress installations
and database driven sites in general


To Do
-----
* Create processes for handling the `uploads` directory


Contents
--------
* `database-pull.sh`:  gets a database from the remote server using via SSH
* `push-with-database.sh`:  pushes the local files and database to the remote
* `database-dump.sh`:  dumps the database in a Git-friendly format
* `database-garbage-collection.php`:  removes backup copies of postings
* `database-load-prod-dump-on-local.sh`:  loads a dump and adjusts WP's URL's
* `lock.sh`:  makes files and directories read-only
* `unlock.sh`:  makes files and directories writable
* `change-url-local.php`:  sets WordPress' site URL to the local/testing value
* `change-url-prod.php`:  sets WordPress' site URL to the live/produciton value


Installation
------------
This is but one way to use this process.  This method permits you to
easily merge my changes into your system.  On your _remote_ server, do the
following:

	mkdir wp
	cd wp
	git init
	git config receive.denyCurrentBranch ignore

	git remote add -t 3.4-branch -f wp \
		https://github.com/WordPress/WordPress
	git checkout -b wp34 wp/3.4-branch

	mkdir public_html
	git mv *.html *.php *.txt public_html
	git mv wp-* public_html
	git commit -am 'Move WP files into public_html.'

	git remote add -t wordpress git_push_deployer \
		git://github.com/convissor/git_push_deployer.git
	git pull git_push_deployer wordpress

	ln -s ../../utilities/post-update .git/hooks/post-update
	ln -s ../../utilities/pre-receive .git/hooks/pre-receive

Then, on your local box:

	git clone ssh://<user>@<host>/<path>/wp
	cd wp

	# Add remotes locally so you can update things here.
	git remote add -t 3.4-branch -f wp \
		https://github.com/WordPress/WordPress
	git remote add -t wordpress git_push_deployer \
		git://github.com/convissor/git_push_deployer.git
	git pull git_push_deployer wordpress

	# Create your development branch.
	git checkout -b dev34

	# Adjust WordPress settings.
	ln -s wp-config-sample.php public_html/wp-config.php
	git add public_html/wp-config.php
	vim public_html/wp-config.php

	# Adjust Git Push Deployer settings.
	vim auth_info.sh
	vim config.inc
	vim config.sh

	git commit -am 'My settings.'

	# Make, add, and commit any other changes you desire.

	# Create the production release branch.
	git checkout -b master

	# Rename the remote to clarify the role (and match config.sh).
	git remote rename origin prod

	# To deploy your changes, do this.
	git push prod master

	# To get any changes I and/or WordPress have made.
	git checkout dev34
	git pull wp
	git merge wp34
	git pull git_push_deployer wordpress
	git checkout master
	git merge dev34
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
