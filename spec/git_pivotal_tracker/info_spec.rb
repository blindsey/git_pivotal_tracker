require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe GitPivotalTracker::Story do
  describe "#run!" do
    context "given no story ID is found" do
      before do
        stub_git_config
        @subject = GitPivotalTracker::Info.new
        @subject.stub!(:story_id).and_return(nil)
      end

      it "fails" do
        @subject.run!.should == 1
      end
    end
  end
end

