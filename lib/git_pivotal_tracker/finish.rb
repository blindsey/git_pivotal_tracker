module GitPivotalTracker
  class Finish < Base

    def run!
      return 1 if super

      unless story_id
        put "Branch name must contain a Pivotal Tracker story id"
        return 1
      end

      if options[:rebase]
        puts "Fetching origin and rebasing #{current_branch}"
        log repository.git.fetch({:raise => true}, "origin")
        log repository.git.rebase({:raise => true}, "origin/#{integration_branch}")
      end

      puts "Merging #{current_branch} into #{integration_branch}"
      log repository.git.checkout({:raise => true}, integration_branch)

      flags = options[:fast_forward] ? {} : {:'no-ff' => true}
      log repository.git.merge({:raise => true}.merge(flags), current_branch)

      puts "Pushing #{integration_branch} to origin"
      log repository.git.push({:raise => true}, "origin", integration_branch)

      puts "Marking Story #{story_id} as finished..."
      if story.update(:current_state => finished_state)
        puts "Success"
        return 0
      else
        puts "Unable to mark Story #{story_id} as finished"
        return 1
      end
    end

    private

    def finished_state
      story.story_type == "chore" ? "accepted" : "finished"
    end
  end
end
