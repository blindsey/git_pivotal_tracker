require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe GitPivotalTracker::Finish do

  before do
    File.delete( "test.txt" ) if File.exists?( "test.txt" )
    stub_request(:get, 'http://www.pivotaltracker.com/services/v3/projects/123').
        to_return :body => File.read("#{FIXTURES_PATH}/project.xml")
    stub_request(:get, 'http://www.pivotaltracker.com/services/v3/projects/123/stories/1234567890').
        to_return :body => File.read("#{FIXTURES_PATH}/story.xml")
    @current_head = finish.repository.head
  end

  after do
    puts finish.repository.git.checkout({}, @current_head.name)
    puts finish.repository.git.reset({}, @current_head.commit.sha)
  end

  let(:finish) { GitPivotalTracker::Finish.new("-t", "8a8a8a8", "-p", "123") }

  context "given I am not on a topic branch" do
    before do
      @new_branch = 'invalid-topic-branch'
      finish.repository.git.branch({:D => true}, @new_branch)
      finish.repository.git.checkout({:b => true, :raise => true}, @new_branch)
    end

    it "fails" do
      finish.run!.should == 1
    end
  end

  context "given I am on a topic branch with a commit" do
    before do
      finish.options[:integration_branch] = @current_head.name

      finish_xml = File.read("#{FIXTURES_PATH}/finish_story.xml")
      stub_request(:put, 'http://www.pivotaltracker.com/services/v3/projects/123/stories/1234567890').
          with(:body => finish_xml).to_return(:body => finish_xml)

      @repo = finish.repository
      @new_branch = "testing-1234567890-branch_name"
      @repo.git.branch({:D => true}, @new_branch)
      @repo.git.checkout({:b => true, :raise => true}, @new_branch)

      index = @repo.index
      index.read_tree @new_branch
      message = "Test commit: #{rand()}"
      index.add('test.txt', message)
      @sha = index.commit(message, [@repo.heads.detect { |h| h.name == @new_branch }.commit], nil, nil, @new_branch)

      @repo.git.should_receive(:push).with({:raise => true}, 'origin', @current_head.name)
    end

    it "merges the topic branch into the integration branch with a merge commit" do
      finish.run!.should == 0
      @repo.head.name.should == @current_head.name
      @repo.commits.first.parents.should have(2).items
      @repo.commits( @current_head.name ).first.sha.should == @sha
    end

    it "does not delete the topic branch" do
      finish.run!.should == 0
      @repo.git.branch.should match @new_branch
    end

    context "when I have rebase turned on" do
      before do
        finish.options[:rebase] = 1
        finish.repository.git.should_receive(:pull).with(:raise => true)
        finish.repository.git.should_receive(:rebase).with({:raise => true}, @current_head.name, @new_branch)
      end

      it "succeeds" do
        finish.run!.should == 0
      end
    end

    context "when I have fast forward turned on" do
      before do
        finish.options[:fast_forward] = 1
      end

      it "merges the topic branch without a merge commit" do
        finish.run!.should == 0
        @repo.heads.detect { |h| h.name == @current_head.name }.commit.sha.should == @sha
      end
    end

    context "when I have delete branch turned on" do
      before do
        finish.options[:delete_branch] = 1
      end

      it "deletes the topic branch after merging" do
        finish.run!.should == 0
        @repo.git.branch.should_not match @new_branch
      end
    end
  end
end
