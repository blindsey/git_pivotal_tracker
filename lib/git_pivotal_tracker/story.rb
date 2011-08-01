module GitPivotalTracker
  class Story < Base

    def run!
      return 1 if super

      puts "Retrieving latest #{type} from Pivotal Tracker"

      unless story = fetch_story
        puts "No #{type} available!"
        return 1
      end

      puts "URL:   #{story.url}"
      puts "Story: #{story.name}"

      print "Enter branch name [#{branch_suffix story}]: "
      suffix = gets.chomp
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
    end

    def type
      self.class.name.downcase.split(/::/).last
    end

    private

    def fetch_story
      state = options[:include_rejected] ? "unstarted,rejected" : "unstarted"
      conditions = { :current_state => state, :limit => 1 }
      conditions[:owned_by] = "\"#{options[:full_name]}\"" if options[:only_mine]
      conditions[:story_type] = type unless type == 'story'
      project.stories.all(conditions).first
    end

    def branch_suffix(story)
      story.name.sub(/^\W+/, '').sub(/\W+$/, '').gsub(/\W+/, '_').downcase
    end
  end

  class Bug < Story; end

  class Feature < Story; end

  class Chore < Story; end
end
