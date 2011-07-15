require File.join(File.dirname(__FILE__), %w[spec_helper])

def stub_git_config(opts={})
  git_options = { "pivotal.api-token"=>"8a8a8a8",
    "pivotal.project-id"=>"123", 
    "pivotal.integration-branch" => nil,
    "pivotal.fast-forward" =>nil, 
    "pivotal.rebase"=>nil, 
    "pivotal.full-name"=>"Mr Rogers",
    "pivotal.verbose"=>nil, 
    "pivotal.use_ssl"=>nil }.merge(opts)
  Grit::Repo.stub!(:new).and_return(mock("Grit::Repo", :config => git_options))
end
  
  
describe GitPivotalTracker do
  describe "commandline options" do
    before(:each) do
      @input = mock('input')
      @output = mock('output')
      stub_git_config
    end

    it "sets use_ssl to 1 with command line argument --use-ssl" do
      pick = GitPivotalTracker::Base.new(@input, @output, "--use-ssl")
      pick.options[:use_ssl].should be
    end
    
    it "sets use_ssl to 1 with command line argument -S" do
      pick = GitPivotalTracker::Base.new(@input, @output, "-S")
      pick.options[:use_ssl].should be
    end
    
    it "leaves use_ssl nil by default" do
      pick = GitPivotalTracker::Base.new(@input, @output, "")
      pick.options[:use_ssl].should be_nil
    end
    
    it "sets use_ssl from git config" do
      stub_git_config({"pivotal.use-ssl" => 1})
      pick = GitPivotalTracker::Base.new
      pick.options[:use_ssl].should be
    end
  end
end
