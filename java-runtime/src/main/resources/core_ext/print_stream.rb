#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require "java"

# Add an alias of PrintStream#write for backward compatibility
# https://github.com/jenkinsci/jenkins.rb/issues/86
java_import java.io.PrintStream
class PrintStream
  java_alias(:write, :print, [java.lang.String])
end

# vim:set ft=ruby :
