# Changelog

## 0.6.3 - 2011/04/12

* fixes for ruby 1.9

## 0.6.2 - 2011/03/17

* add `build_details` command for fetching the result of a particular build.
* add instructions for running with non-english locale
* remove, fix obsolete gem dependencies

## 0.5.0 - 2010/12/1

* hudson warfile no longer bundled with hudson gem
  * rubygem is now 235K instead of 31M!
  * upgrade hudson server and related plugins without requiring a new gem release
* hudson gem now fully drinks the bundler koolaid.
* hudson create
  * --node-labels 'ubuntu,gentoo' - run tests against multiple slave nodes by their label
  * --no-template - do not generate any default steps (well, a silly one)
* hudson add_node
  * --vagrant - provide alternate default values when adding nodes if the node is a Vagrant VM
* hudson default_host
  * NEW - displays the current default host:port URI

## 0.4.0 - 2010/11/11

* hudson create
  * --rubies '1.8.7,1.9.2,rbx-head,jruby' - uses RVM and Hudson's Axes support to run tests within different Ruby environments
  * --scm git://some-alternate.com/repo.git - can override the "origin" URI
  * --scm-branches 'master,other,branches' - specify which branches can be pulled from to trigger tests

* hudson job
  * Can dump information/status about a job

## 0.3.1 - 2010/11/8

* fixed error in the rails3 template's test for schema.rb

## 0.3.0 - 2010/11/8

MAJOR RELEASE!

* All new commands for CLI: build, remove, nodes, add_node
* Updated to Hudson CI 1.381

## 0.2.7 2010/8/25

* Updated to Hudson CI 1.373
