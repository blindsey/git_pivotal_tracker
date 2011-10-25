Given /^the following git repo:$/ do |table|
  hash = table.hashes.first
  api_token, project_id = hash['Pivotal Tracker Api Token/Project Id'].split '/'
  steps %Q{
    Given a directory named "#{hash[:Name]}"
      And I cd to "#{hash[:Name]}"
      And I run `git init`
      And I run `git config --local pivotal.api-token #{api_token}`
      And I run `git config --local pivotal.project-id #{project_id}`
      And an empty file named "README"
      And I run `git add .`
      And I run `git commit -m "Initial Commit"`
  }
end
