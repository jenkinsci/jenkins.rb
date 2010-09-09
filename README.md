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
    gem install hudson --pre (bleeding edge)

Example
=======

Hudson.rb is continuously tested using Hudson at [http://hudson.thefrontside.net/job/hudson.rb/](http://hudson.thefrontside.net/job/hudson.rb/).

The `hudson` application allows you to see the projects/jobs and their statuses:

    $ hudson list --host hudson.thefrontside.net --port 80
    hudson.rb - http://hudson.thefrontside.net/job/hudson.rb/
    TheRubyRacer - http://hudson.thefrontside.net/job/TheRubyRacer/
    
    # alternately use environment variables
    $ HUDSON_HOST=hudson.thefrontside.net HUDSON_PORT=80 hudson list

Usage
=====

To run Hudson server:

    Usage: hudson server [HUDSON_HOME] [options]
        -d, --daemon                     fork into background and run as daemon
        -p, --port [3001]                run hudson on specified port 
        -c, --control-port [3002]        set the shutdown/control port
        -k, --kill                       send shutdown signal to control port
        -v, --version                    show version information
        -h, --help

Note: HUDSON_HOME defaults to ~/.hudson

To list Jobs/Projects on a Hudson server:

    Usage: hudson list [project_path] [options]
        -p, --port [3001]                find hudson on specified port
            --host [localhost]           find hudson on specified host
        -h, --help

To add Project (create a Job) on a Hudson server:

    Usage: hudson create [project_path] [options]
        -n, --name [dir_name]            name of hudson job
        -p, --port [3001]                find hudson on specified port
            --host [localhost]           find hudson on specified host
        -h, --help

For all commands, if flags for `host:port` are not provided, it will use `$HUDSON_HOST` and `$HUDSON_PORT` if available.

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