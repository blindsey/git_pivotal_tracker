module GitPivotalTracker
  class Story < Base

    def run!
      return 1 if super

      puts "Retrieving latest #{type} from Pivotal Tracker"
      story = nil
      if options[:interactive]
        stories = fetch_stories(10)
        stories.each_with_index do |s, i|
          puts "#{i}) #{s.story_type} #{s.id} #{s.name}"
        end
        print "Pick a story: "
        story = stories[STDIN.gets.chomp.to_i]
      else
        story = fetch_stories.first
      end

      unless story
        puts "No #{type} available!"
        return 1
      end

      puts "URL:   #{story.url}"
      puts "Story: #{story.name}"

      print "Enter branch name [#{branch_suffix story}]: "
      suffix = STDIN.gets.chomp
      suffix = branch_suffix(story) if suffix == ""

      branch = "#{story.story_type}-#{story.id}-#{suffix}"
      puts "Checking out a new branch '#{branch}'"
      log repository.git.checkout({:b => true, :raise => true}, branch)

      puts "Updating #{type} status in Pivotal Tracker..."
      if story.update(:owned_by => options[:full_name], :current_state => :started)
        puts "Success"
        return 0
      else
        puts "Unable to mark #{type} as started"
        return 1
      end
    rescue Grit::Git::CommandFailed => e
      puts "git error: #{e.err}"
      return 1
    end

    def type
      self.class.name.downcase.split(/::/).last
    end

    private

    def fetch_stories(count = 1)
      state = options[:include_rejected] ? "unstarted,rejected" : "unstarted"
      conditions = { :current_state => state, :limit => count }
      conditions[:story_type] = type == 'story' ? 'bug,chore,feature' : type
      conditions[:owned_by] = "\"#{options[:full_name]}\"" if options[:only_mine]
      project.stories.all(conditions)
    end

    def branch_suffix(story)
      story.name.sub(/^\W+/, '').sub(/\W+$/, '').gsub(/\W+/, '_').downcase
    end
  end

  class Bug < Story; end

  class Feature < Story; end

  class Chore < Story; end
end
