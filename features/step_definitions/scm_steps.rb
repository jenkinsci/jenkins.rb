Given /^the project uses "git" scm$/ do
  repo = "git://some.host/drnic/ruby.git"
  in_project_folder do
    unless File.exist?(".git")
      %x[ git init ]
      %x[ git add . ]
      %x[ git commit -m "initial commit" ]
      %x[ git remote add origin #{repo} ]
    end
  end
end

