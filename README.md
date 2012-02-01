Jenkins
======

[Jenkins CI](http://jenkins-ci.org/) is a sweet continuous integration
platform. Jenkins.rb makes it easy to get started, add/remove Ruby
jobs and slave nodes; either from a CLI or an API.


  * Email: [http://groups.google.com/group/jenkinsrb](http://groups.google.com/group/jenkinsrb)
  * IRC:  [irc://irc.freenode.net/jenkins.rb](irc://irc.freenode.net/jenkins.rb)
  * CI: [http://travis-ci.org/cowboyd/jenkins.rb](http://travis-ci.org/cowboyd/jenkins.rb)

Install
=======

    gem install jenkins

You do not need to download Jenkins CI. It is bundled in the RubyGem.

Example
=======

Jenkins.rb is continuously tested using Jenkins at [http://jenkins.thefrontside.net/job/jenkins.rb/](http://jenkins.thefrontside.net/job/jenkins.rb/).

The `jenkins` application allows you to see the projects/jobs and their statuses:

    $ jenkins list --host jenkins.thefrontside.net --port 80
    jenkins.rb - http://jenkins.thefrontside.net/job/jenkins.rb/
    TheRubyRacer - http://jenkins.thefrontside.net/job/TheRubyRacer/

Alternately use environment variables:

    $ JENKINS_HOST=jenkins.thefrontside.net JENKINS_PORT=80 jenkins list

Alternately, it will remember the last Jenkins CI master used.

    $ jenkins list

Usage
=====

To run your own Jenkins server (by default opens at http://localhost:3001):

    Usage: jenkins server [options]
      -p,  --port [3001]                         run jenkins server on this port
      -c,  --control [3002]                      set the shutdown/control port
           --daemon                              fork into background and run as a daemon
           --logfile [PATH]                      redirect log messages to this file
      -k,  --kill                                send shutdown signal to control port
           --home [/Users/drnic/.jenkins/server]  use this directory to store server data

The remaining CLI tasks are for communicating with a running Jenkins server; either the one created above or hosted remotely.

### Jobs

To list Jobs/Projects on a Jenkins server:

    Usage: jenkins list [options]

To add Jobs/Projects (create a Job) on a Jenkins server:

    Usage: jenkins create PROJECT_PATH [options]
        --public-scm                     	  use public scm URL
        --template [ruby]                	  template of job steps (available: rails,rails3,ruby,rubygem,erlang)
                                                  or specify a file or URI from which to read raw XML config
        --assigned-node [ASSIGNED-NODE]  	  only use slave nodes with this label
        --override                       	  override if job exists
        --no-build                       	  create job without initial build

To trigger a Job to build:

    Usage: jenkins build

To remove a Job from a Jenkins server:

    Usage: jenkins remove PROJECT_PATH

### Slave nodes

To list slaves on a Jenkins server (including itself):

    Usage: jenkins nodes

To add a remote machine/remote VM to a Jenkins server as a slave:

    Usage: jenkins add_node SLAVE_HOST
        --slave-port [22]          	  SSH port for Jenkins to connect to slave node
        --label [LABEL]            	  Labels for a job --assigned_node to match against to select a slave.         --master-key [MASTER-KEY]  	  Location of master public key or identity file
        --slave-fs [SLAVE-FS]      	  Location of file system on slave for Jenkins to use
        --name [NAME]              	  Name of slave node (default SLAVE_HOST)
        --slave-user [deploy]      	  SSH user for Jenkins to connect to slave node

### Selecting a Jenkins CI server

**For all client-side commands, there are `--host` and `--port` options flags.** These are cached after first used, so are only required for the first request to a Jenkins CI server. For example:

    jenkins create . --host localhost --port 3001
    jenkins list
    jenkins create . --override

Alternately, `$JENKINS_HOST` and `$JENKINS_PORT` can be provided in lieu of the cached target Jenkins CI server

    JENKINS_HOST=localhost JENKINS_PORT=3001 jenkins list


Developer Instructions
======================

The dependencies for the gem and for developing the gem are managed by Bundler.

    gem install bundler
    git clone http://github.com/cowboyd/jenkins.rb.git
    bundle install

The test suites expects Jenkins to speak English. If you are not using an
English locale prepare the terminal session running the test suite with:

    export LC_ALL=en_US.UTF-8

The test suite is run with:

    rake

This launches a Jenkins server, runs cucumber features, and kills the Jenkins server.

Alternately, manually launch the Jenkins server, run features and close the Jenkins server:

    rake jenkins:server:test
    rake cucumber:ok
    rake jenkins:server:killtest

Contributors
============

* Charles Lowell
* Dr Nic Williams
* Bo Jeanes

License
=======

(The MIT License)

Copyright (c) 2010 Charles Lowell, cowboyd@thefrontside.net

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
