require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe GitPivotalTracker::Story do
  describe "#run!" do
    before do
      stub_request(:get, 'http://www.pivotaltracker.com/services/v3/projects/123').
          to_return :body => File.read("#{FIXTURES_PATH}/project.xml")
    end

    let(:story) { GitPivotalTracker::Story.new("-t", "8a8a8a8", "-p", "123") }

    context "given there are no stories" do
      before do
        stub_request(:get, 'http://www.pivotaltracker.com/services/v3/projects/123/stories?filter=current_state:unstarted&limit=1').
            to_return :body => File.read("#{FIXTURES_PATH}/no_stories.xml")
      end

      it "fails" do
        story.run!.should == 1
      end
    end

    context "given there is a story" do
      before do
        start_xml = File.read("#{FIXTURES_PATH}/start_story.xml")
        stub_request(:get, 'http://www.pivotaltracker.com/services/v3/projects/123/stories?filter=current_state:unstarted&limit=1').
            to_return :body => File.read("#{FIXTURES_PATH}/one_story.xml")
        stub_request(:put, 'http://www.pivotaltracker.com/services/v3/projects/123/stories/1234567890').
            with(:body => start_xml).to_return(:body => start_xml)

        @current_branch = story.repository.head.name
      end

      context "then I accept the default branch suffix" do
        before do
          @expected_branch = 'feature-1234567890-pause_the_film'
          story.repository.git.branch({:D => true}, @expected_branch)

          story.should_receive(:gets).and_return "\n"
          story.run!
        end

        it "creates a new branch" do
          story.repository.head.name.should == @expected_branch
        end
      end

      context "then I customize the branch suffix" do
        before do
          @expected_branch = 'feature-1234567890-new_name'
          story.repository.git.branch({:D => true}, @expected_branch)

          story.should_receive(:gets).and_return "new_name\n"
          story.run!
        end

        it "creates a new branch" do
          story.repository.head.name.should == @expected_branch
        end
      end

      after do
        story.repository.git.checkout({:raise => true}, @current_branch)
      end
    end

  end

  describe "#type" do
    it "is a story" do
      GitPivotalTracker::Story.new.type.should == 'story'
    end
  end
end

describe GitPivotalTracker::Bug do
  describe "#type" do
    it "is a bug" do
      GitPivotalTracker::Bug.new.type.should == 'bug'
    end
  end
end

describe GitPivotalTracker::Feature do
  describe "#type" do
    it "is a feature" do
      GitPivotalTracker::Feature.new.type.should == 'feature'
    end
  end
end

describe GitPivotalTracker::Chore do
  describe "#type" do
    it "is a chore" do
      GitPivotalTracker::Chore.new.type.should == 'chore'
    end
  end
end

