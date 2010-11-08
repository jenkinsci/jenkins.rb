Hudson
======

Hudson is a sweet continuous integration platform. Hudson.rb makes it easy
to bundles all the things you need to easily run a hudson server from Ruby,
as well as talk to a running hudson servers from Ruby and the command line.

  * Email: [http://groups.google.com/group/hudsonrb](http://groups.google.com/group/hudsonrb)
  * IRC:  [irc://irc.freenode.net/hudson.rb](irc://irc.freenode.net/hudson.rb)

Install
=======

    gem install hudson

You do not need to download Hudson CI. It is bundled in the RubyGem.

Example
=======

Hudson.rb is continuously tested using Hudson at [http://hudson.thefrontside.net/job/hudson.rb/](http://hudson.thefrontside.net/job/hudson.rb/).

The `hudson` application allows you to see the projects/jobs and their statuses:

    $ hudson list --host hudson.thefrontside.net --port 80
    hudson.rb - http://hudson.thefrontside.net/job/hudson.rb/
    TheRubyRacer - http://hudson.thefrontside.net/job/TheRubyRacer/

Alternately use environment variables:

    $ HUDSON_HOST=hudson.thefrontside.net HUDSON_PORT=80 hudson list

Alternately, it will remember the last Hudson CI master used.

    $ hudson list

Usage
=====

To run your own Hudson server (by default opens at http://localhost:3001):

    Usage: hudson server [options]
      -p,  --port [3001]                         run hudson server on this port
      -c,  --control [3002]                      set the shutdown/control port
           --daemon                              fork into background and run as a daemon
           --logfile [PATH]                      redirect log messages to this file
      -k,  --kill                                send shutdown signal to control port
           --home [/Users/drnic/.hudson/server]  use this directory to store server data

The remaining CLI tasks are for communicating with a running Hudson server; either the one created above or hosted remotely.

### Jobs

To list Jobs/Projects on a Hudson server:

    Usage: hudson list [options]

To add Jobs/Projects (create a Job) on a Hudson server:

    Usage: hudson create PROJECT_PATH [options]
        --public-scm                     	  use public scm URL
        --template [ruby]                	  template of job steps (available: rails,rails3,ruby,rubygem)
        --assigned-node [ASSIGNED-NODE]  	  only use slave nodes with this label
        --override                       	  override if job exists
        --no-build                       	  create job without initial build

To trigger a Job to build:

    Usage: hudson build

To remove a Job from a Hudson server:

    Usage: hudson remove PROJECT_PATH

### Slave nodes

To list slaves on a Hudson server (including itself):

    Usage: hudson nodes

To add a remote machine/remote VM to a Hudson server as a slave:

    Usage: hudson add_node SLAVE_HOST
        --slave-port [22]          	  SSH port for Hudson to connect to slave node
        --label [LABEL]            	  Labels for a job --assigned_node to match against to select a slave.         --master-key [MASTER-KEY]  	  Location of master public key or identity file
        --slave-fs [SLAVE-FS]      	  Location of file system on slave for Hudson to use
        --name [NAME]              	  Name of slave node (default SLAVE_HOST)
        --slave-user [deploy]      	  SSH user for Hudson to connect to slave node
    

### Selecting a Hudson CI server

**For all client-side commands, there are `--host` and `--port` options flags.** These are cached after first used, so are only required for the first request to a Hudson CI server. For example:

    hudson create . --host localhost --port 3001
    hudson list
    hudson create . --override

Alternately, `$HUDSON_HOST` and `$HUDSON_PORT` can be provided in lieu of the cached target Hudson CI server

    HUDSON_HOST=localhost HUDSON_PORT=3001 hudson list


Developer Instructions
======================

The dependencies for the gem and for developing the gem are managed by bundler.

    gem install bundler
    git clone http://github.com/cowboyd/hudson.rb.git
    bundle install

The test suite is run with:

    rake

This launches a Hudson server, runs cucumber features, and kills the Hudson server.

Alternately, manually launch the Hudson server, run features and close the Hudson server:

    rake hudson:server:test
    rake cucumber:ok
    rake hudson:server:killtest

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