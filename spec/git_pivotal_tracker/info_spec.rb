require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe GitPivotalTracker::Story do
  describe "#run!" do
    before do
      stub_git_config
      stub_request(:get, 'http://www.pivotaltracker.com/services/v3/projects/123').
          to_return :body => File.read("#{FIXTURES_PATH}/project.xml")
      @story = GitPivotalTracker::Info.new("-t", "8a8a8a8", "-p", "123")
    end

    context "given no story ID is found" do
      before do
        @story.stub!(:story_id).and_return(nil)
      end

      it "fails" do
        @story.run!.should == 1
      end
    end

    context "given a story exists" do
      before do
        @story.stub!(:story_id).and_return('1234567890')
        stub_request(:get, 'http://www.pivotaltracker.com/services/v3/projects/123/stories/1234567890').
            to_return :body => File.read("#{FIXTURES_PATH}/story.xml")
        stub_request(:get, 'http://www.pivotaltracker.com/services/v3/projects/123/stories/1234567890/notes').
            to_return :body => File.read("#{FIXTURES_PATH}/notes.xml")
      end

      it "outputs correctly" do
        @story.should_receive(:puts).with("URL:           http://www.pivotaltracker.com/story/show/1234567890")
        @story.should_receive(:puts).with("Story:          Pause the film!")
        @story.should_receive(:puts).with("Description:   As a moderator,\nI can pause the film\nIn order to allow another activity to take place (discussion, etc).")
        @story.should_receive(:puts).with("Comments:      Testing comments")
        @story.run!.should == 0
      end
    end
  end
end

