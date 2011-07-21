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

      default_suffix = story.name.downcase.strip.gsub(/\W+/, '_')
      print "Enter branch name [#{default_suffix}]: "
      suffix = gets.chomp
      suffix = default_suffix if suffix == ""

      branch = "#{story.story_type}-#{story.id}-#{suffix}"
      puts "Checking out a new branch '#{branch}'"
      log repository.git.checkout({:b => true, :raise => true}, branch)

      puts "Updating #{type} status in Pivotal Tracker..."
      if story.update(:owned_by => options[:name], :current_state => :started)
        puts "Success"
        return 0
      else
        puts "Unable to mark #{type} as started"
        return 1
      end
    end

    private

    def type
      self.class.name.downcase.split(/::/).last
    end

    def fetch_story
      # TODO: check for rejected stories as well
      conditions = { :current_state => "unstarted", :limit => 1, :offset => 0 }
      conditions[:story_type] = type unless type == 'story'
      project.stories.all(conditions).first
    end
  end

  class Bug < Story; end

  class Feature < Story; end

  class Chore < Story; end
end
