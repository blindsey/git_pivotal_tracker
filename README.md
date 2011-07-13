git-tracker
===========

Inspired by [Hashrocket's blend of git and Pivotal Tracker](http://reinh.com/blog/2009/03/02/a-git-workflow-for-agile-teams.html) and [a popular article on effective git workflows](http://blog.carbonfive.com/2010/11/01/integrating-topic-branches-in-git/), I wanted to build a tool to simplify the workflow between the two.

Features
--------

* `git-feature`
* `git-bug`
* `git-chore`
These commands collect the first available story from your Pivotal Tracker project and create a topic branch for it.

* `git-finish`
When on a topic branch, this command will fetch the latest integration branch ('master' by default), rebase your topic branch from it, merge the branch into the integration branch with no-fast-forword and push the integration branch to origin.

Examples
--------

    FIXME (code sample of usage)

Requirements
------------

* github
* tracker project
* github to tracker api integration turned on

Install
-------

* gem install git_pivotal_tracker

Once installed, git pivotal needs two bits of info: your Pivotal Tracker API Token and your Pivotal Tracker project id:

   git config --global pivotal.api-token 123a456b

The project id is best placed within your project's git config:

   git config -f .git/config pivotal.project-id 88888

If you prefer to merge back to a branch other than master when you've finished a story, you can configure that:

   git config --global pivotal.integration-branch develop

Author
------

* Ben Lindsey <ben@carbonfive.com>

Contributors
------

License
-------

(The MIT License)

Copyright (c) 2011 Ben Lindsey

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
