# Jenkins plugins

Provide the facility to create, develop and release extensions for [Jenkins](http://jenkins-ci.org) with nothing but knowledge of the language, tools and best practices of the Ruby community.

[read more](http://blog.thefrontside.net/2011/05/12/what-it-take-to-bring-ruby-to-jenkins)...

# Get started

Using JRuby, install the plugin tools

    $ gem install jpi

The gem provides the `jpi` executeable

    $ jpi -h

    jpi- tools to create, build, develop and release Jenkins plugins

    Usage: jpi command [arguments] [options]

    Commands:
      jpi help [COMMAND]  # get help for COMMAND, or for jpi itself
      jpi new NAME        # create a new plugin called NAME
      jpi generate        # generate code for extensions points
      jpi build           # build plugin into .hpi file suitable for distribution
      jpi server          # run a test server with plugin
      jpi version         # show jpi version information

The first thing you'll probably want to do is create a new ruby plugin.

    $ jpi new one-great-plugin
          create  one-great-plugin/Gemfile
          create  one-great-plugin/one-great-plugin.pluginspec

This will create a minimal plugin project structure, to which you can add later.
Once you have your plugin created, you can run a server with it loaded

    $ cd one-great-plugin
    $ jpi server

    Listening for transport dt_socket at address: 8000
    webroot: System.getProperty("JENKINS_HOME")
    [Winstone 2011/09/19 12:01:36] - Beginning extraction from war file
    [Winstone 2011/09/19 12:01:37] - HTTP Listener started: port=8080
    [Winstone 2011/09/19 12:01:37] - AJP13 Listener started: port=8009
    [Winstone 2011/09/19 12:01:37] - Winstone Servlet Engine v0.9.10 running: controlPort=disabled
    Sep 19, 2011 12:01:37 PM jenkins.model.Jenkins$6 onAttained
    INFO: Started initialization
    Sep 19, 2011 12:01:38 PM hudson.PluginManager$1$3$1 isDuplicate
    Sep 19, 2011 12:01:39 PM jenkins.model.Jenkins$6 onAttained
    INFO: Listed all plugins
    Sep 19, 2011 12:01:39 PM ruby.RubyRuntimePlugin start
    INFO: Injecting JRuby into XStream
    Sep 19, 2011 12:01:49 PM jenkins.model.Jenkins$6 onAttained
    INFO: Prepared all plugins
    Sep 19, 2011 12:01:49 PM jenkins.model.Jenkins$6 onAttained
    INFO: Started all plugins
    Sep 19, 2011 12:01:49 PM jenkins.model.Jenkins$6 onAttained
    INFO: Augmented all extensions
    Sep 19, 2011 12:01:49 PM jenkins.model.Jenkins$6 onAttained
    INFO: Loaded all jobs
    Sep 19, 2011 12:01:51 PM jenkins.model.Jenkins$6 onAttained
    INFO: Completed initialization
    Sep 19, 2011 12:01:51 PM hudson.TcpSlaveAgentListener <init>
    INFO: JNLP slave agent listener started on TCP port 52262
    Sep 19, 2011 12:02:01 PM hudson.WebAppMain$2 run
    INFO: Jenkins is fully up and running

Of course, this plugin isn't actually doing anything because we haven't defined any extension
points. Let's go ahead and create one of the most common extension points: a `Builder`

    $ jpi generate builder logging




