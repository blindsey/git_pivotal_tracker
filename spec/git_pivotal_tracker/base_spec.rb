require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe GitPivotalTracker::Base do
  describe "#parse_argv" do

    context "by default" do
      before do
        stub_git_config
        subject = GitPivotalTracker::Base.new
      end

      it "leaves integration_branch nil" do
        subject.options[:integration_branch].should be_nil
      end

      it "leaves full_name nil" do
        subject.options[:full_name].should be_nil
      end

      [:fast_forward, :rebase, :verbose, :use_ssl, :include_rejected, :only_mine].each do |key|
        it "does not set #{key}" do
          subject.options[key].should_not be
        end
      end
    end

    it "sets the api_token" do
      GitPivotalTracker::Base.new("--api-token", "8a8a8a8").options[:api_token].should == '8a8a8a8'
      GitPivotalTracker::Base.new("-t", "8a8a8a8").options[:api_token].should == '8a8a8a8'
    end

    it "sets the project_id" do
      GitPivotalTracker::Base.new("--project-id", "123").options[:project_id].should == '123'
      GitPivotalTracker::Base.new("-p", "123").options[:project_id].should == '123'
    end

    it "sets the integration_branch" do
      GitPivotalTracker::Base.new("--integration-branch", "development").options[:integration_branch].should == 'development'
      GitPivotalTracker::Base.new("-b", "development").options[:integration_branch].should == 'development'
    end

    it "sets full_name" do
      GitPivotalTracker::Base.new("--full-name", "Full Name").options[:full_name].should == 'Full Name'
      GitPivotalTracker::Base.new("-n", "Full Name").options[:full_name].should == 'Full Name'
    end

    it "sets include_rejected" do
      GitPivotalTracker::Base.new("--include-rejected").options[:include_rejected].should be
      GitPivotalTracker::Base.new("-I").options[:include_rejected].should be
    end

    it "sets only_mine" do
      GitPivotalTracker::Base.new("--only-mine").options[:only_mine].should be
      GitPivotalTracker::Base.new("-O").options[:only_mine].should be
    end

    it "sets fast_forward" do
      GitPivotalTracker::Base.new("--fast-forward").options[:fast_forward].should be
      GitPivotalTracker::Base.new("-F").options[:fast_forward].should be
    end

    it "sets use_ssl" do
      GitPivotalTracker::Base.new("--use-ssl").options[:use_ssl].should be
      GitPivotalTracker::Base.new("-S").options[:use_ssl].should be
    end

    it "sets rebase" do
      GitPivotalTracker::Base.new("--rebase").options[:rebase].should be
      GitPivotalTracker::Base.new("-R").options[:rebase].should be
    end

    it "sets verbose" do
      GitPivotalTracker::Base.new("--verbose").options[:verbose].should be
      GitPivotalTracker::Base.new("-V").options[:verbose].should be
    end
  end

  describe "#parse_gitconfig" do
    context "with a full-name" do
      before do
        stub_git_config 'pivotal.full-name' => 'Full Name', 'user.name' => 'User Name'
        subject = GitPivotalTracker::Base.new
      end

      it "sets the full_name to the full name" do
        subject.options[:full_name].should == 'Full Name'
      end
    end

    context "with no full-name" do
      before do
        stub_git_config({
          'user.name' => 'User Name',
          'pivotal.integration-branch' => 'development',
          'pivotal.only-mine' => '1',
          'pivotal.include-rejected' => '1',
          'pivotal.fast-forward' => '1',
          'pivotal.rebase' => '1',
          'pivotal.verbose' => '1',
          'pivotal.use-ssl' => '1'
        })
        subject = GitPivotalTracker::Base.new
      end

      it "sets use_ssl" do
        subject.options[:use_ssl].should be
      end

      it "sets the api_token" do
        subject.options[:api_token].should == '8a8a8a8'
      end

      it "sets the project_id" do
        subject.options[:project_id].should == '123'
      end

      [:only_mine, :include_rejected, :fast_forward, :rebase, :verbose, :use_ssl].each do |key|
        it "sets #{key}" do
          subject.options[key].should be
        end
      end

      it "sets the full_name to the user name" do
        subject.options[:full_name].should == 'User Name'
      end
    end

    context "with options set to 0" do
      before do
        stub_git_config({
          'pivotal.only-mine' => '0',
          'pivotal.include-rejected' => '0',
          'pivotal.fast-forward' => '0',
          'pivotal.rebase' => '0',
          'pivotal.verbose' => '0',
          'pivotal.use-ssl' => '0'
        })
        subject = GitPivotalTracker::Base.new
      end

      [:only_mine, :include_rejected, :fast_forward, :rebase, :verbose, :use_ssl].each do |key|
        it "does not set #{key}" do
          subject.options[key].should_not be
        end
      end
    end
  end

  describe ".new" do
    context "given an invalid git root" do
      before do
        @current_dir = Dir.pwd
        Dir.chdir("/")
      end

      it "fails to initialize" do
        expect { GitPivotalTracker::Base.new }.to raise_error "No .git directory found"
      end

      after do
        Dir.chdir @current_dir
      end
    end

    context "given no prepare-commit-msg hook" do
      let(:file_name) { ".git/hooks/prepare-commit-msg" }

      before do
        File.delete file_name if File.exists? file_name
        GitPivotalTracker::Base.new
      end

      it "installs the hook" do
        File.executable?(file_name).should be
      end
    end
  end

  describe "#run!" do
    context "given a config with an api token and a project id" do
      before do
        stub_git_config
        subject = GitPivotalTracker::Base.new
        PivotalTracker::Client.should_receive(:token=).with('8a8a8a8')
      end

      it "succeeds" do
        subject.run!.should be_nil
      end
    end

    context "given the config has no api token" do
      before do
        stub_git_config 'pivotal.api-token' => nil
        subject = GitPivotalTracker::Base.new
      end

      it "fails" do
        subject.run!.should == 1
      end
    end

    context "given the config has no project id" do
      before do
        stub_git_config 'pivotal.project-id' => nil
        subject = GitPivotalTracker::Base.new
      end

      it "fails" do
        subject.run!.should == 1
      end
    end
  end
end
