Hudson
======

Hudson is a sweet CI server. Hudson.rb makes it easy
to run ruby builds by bundling all the ruby-centric plugins 
(ruby, rake, git, github) and wrapping them in a super simple 
executeable.

Install
=======

    gem install hudson

Example
=======

Hudson.rb is continuously tested using Hudson at [http://hudson.thefrontside.net/job/hudson.rb/](http://hudson.thefrontside.net/job/hudson.rb/).

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

