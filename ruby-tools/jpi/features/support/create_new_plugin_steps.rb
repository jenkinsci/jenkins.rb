When /^I run "([^"]*)"$/ do |cmd|
  run cmd
end

Then /^I should see this structure$/ do |structure|
  fail "no match" unless DirectoryStructure.new(structure).matches? work_dir
end