#@title Design Goals

Design goals
============

automate git server maintainance
deploy code with git push
be informed of changes on disk on the server
automatically push or pull or receive push or pull from other servers like github

steps:

- parse an options file
- install gitolite
- configure gitolite user accounts on the server

- sync bases itself on the information of the configuration file in order to make sure that:
  - that the repo exists in gitolite
  - that the repo is checked out on the server
  - that all the correct hooks and triggers are present
  - that the filesystem is in sync with gitolite
  - that the ownership of the files is correct
  - that the permissions of the files are correct

- status checks all the conditions for sync plus:
  - that the user who runs gitomate has the permissions to do all the operations needed
  - generates reports of anything that isn't the way it should be

- the configuration file declares a state the system should be in
