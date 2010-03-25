Hudson
======

Hudson is a sweet CI server. Hudson.rb makes it super simple
to run ruby builds by bundling all the ruby-centric plugins 
(ruby, rake, git, github) and wrapping them in a super simple 
executeable.

Install
=======

    gem install hudson

Use
===

    Usage: hudson [options] HUDSON_HOME
        -d, --daemon                     fork into background and run as daemon
        -p, --port [3001]                run hudson on specified port 
        -c, --control-port [3002]        set the shutdown/control port
        -k, --kill                       send shutdown signal to control port
        -v, --version                    show version information
        -h, --help

