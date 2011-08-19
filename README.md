# Jenkins plugins

Provide the facility to create, develop and release extensions for [Jenkins](http://jenkins-ci.org) with nothing but knowledge of the language, tools and best practices of the Ruby community.

[read more](http://blog.thefrontside.net/2011/05/12/what-it-take-to-bring-ruby-to-jenkins)...

# Get started

> This is all very theoretical. Don't try this at home.

    $ gem install jenkins-plugins
    $ jpi create my-awesome-jenkins-plugin
    $ cd my-awesome-jenkins-plugin
    $ jpi gen build_wrapper MyBuildWrapper
    $ rake server

