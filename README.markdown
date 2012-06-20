Git Push Deployer
=================

A pair of Git hooks, plus some other scripts, that let you deploy
projects using `git push`.


Installation
------------

On your remote server:

	git clone git://github.com/convissor/git_push_deployer.git

	mkdir <project>
	cd <project>
	git init
	git config receive.denyCurrentBranch ignore

	cp -R ../git_push_deployer/* .
	ln -s ../../utilities/post-update .git/hooks/post-update
	ln -s ../../utilities/pre-receive .git/hooks/pre-receive

	git add .
	git commit -am 'Initial commit.'

	# Add any special needs you have to the "utilities/pre_deploy_script"
	# and "utilities/post_deploy_script" scripts.  Then commit them:
	git commit -am 'My customizations to the pre/post deploy scripts.'

On your local box:

	git clone ssh://<user>@<host>/<path>
	cd <project>
	# Make, add, and commit the changes you desire.
	git push origin master


Inspiration
-----------
This project was inspired by http://utsl.gen.nz/git/post-update.
Restructuring it to include a pre-receive script permits using the system
with repositories that don't have any commits and utilize files in the
"utilities" directory without running into the following errors:
* `fatal: bad revision 'HEAD'`
* `warning: Log .git/logs/HEAD has gap after`
