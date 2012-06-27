Git Push Deployer
=================

A pair of Git hooks, plus some other scripts, that let you deploy
projects using `git push`.


Branches
--------
* __master__:  tools for deploying standard, file based sites
* __database__:  utilities for managing database driven sites
* __wordpress__:  additional utilities for managing WordPress installations


Installation
------------
This is but one way to use this process.  This method permits you to
easily merge my changes into your system.  On your _remote_ server, do the
following:

	git clone git://github.com/convissor/git_push_deployer.git

	mv git_push_deployer <your project name>
	cd <your project name>
	git config receive.denyCurrentBranch ignore

	ln -s ../../utilities/post-update .git/hooks/post-update
	ln -s ../../utilities/pre-receive .git/hooks/pre-receive

Then, on your local box:

	git clone ssh://<user>@<host>/<path>/<your project name>
	cd <your project name>
	git remote add git_push_deployer git://github.com/convissor/git_push_deployer.git

	# Make, add, and commit the changes you desire.

	# To deploy your changes, do this:
	git push origin master

	# To get any changes I've made to the system:
	git pull git_push_deployer master
	git push origin master


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
