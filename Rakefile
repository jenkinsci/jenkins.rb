
desc "Grab the latest hudson.war from hudson-ci.org"
task :getwar do
  sh "cd lib/hudson && rm hudson.war && wget http://hudson-ci.org/latest/hudson.war"
end

desc "Clean up"
task :clean do
  sh "rm -rf *.gem"
end