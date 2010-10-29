Given /^I am in the "([^\"]*)" project folder$/ do |project|
  project_folder = File.expand_path(File.dirname(__FILE__) + "/../../fixtures/projects/#{project}")
  in_tmp_folder do
    FileUtils.cp_r(project_folder, project)
    setup_active_project_folder(project)
  end
end

