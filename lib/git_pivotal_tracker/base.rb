module GitPivotalTracker
  class Base
    GIT_DIR = ENV['GIT_DIR'] || '.git'

    attr_reader :options, :repository

    def initialize(*args)
      directories = Dir.pwd.split(::File::SEPARATOR)
      begin
        break if File.directory?(File.join(*directories, GIT_DIR))
      end while directories.pop

      raise "No #{GIT_DIR} directory found" if directories.empty?
      root = File.join(*directories, GIT_DIR)
      @repository = Grit::Repo.new(root)

      new_hook_path = File.join(*directories, GIT_DIR, 'hooks', 'prepare-commit-msg')
      unless File.executable?(new_hook_path)
        puts "Installing prepare-commit-msg hook..."
        old_hook_path = File.join(File.dirname(__FILE__), '..', '..', 'bin', 'prepare-commit-msg')
        FileUtils.cp(old_hook_path, new_hook_path, :preserve => true)
      end

      @options = {}
      parse_gitconfig
      parse_argv(*args)
    end

    def run!
      unless options[:api_token] && options[:project_id]
        puts "Pivotal Tracker API Token and Project ID are required"
        return 1
      end

      PivotalTracker::Client.token = options[:api_token]
      nil
    end

    protected

    def integration_branch
      options[:integration_branch] || 'master'
    end

    def current_branch
      @current_branch ||= repository.head.name
    end

    def story_id
      @story_id ||= current_branch[/\d+/].to_i
    end

    def project
      @project ||= PivotalTracker::Project.find(options[:project_id])
    end

    def story
      @story ||= project.stories.find(story_id)
    end

    def log(message)
      puts message if options[:verbose]
    end

    private

    def parse_gitconfig
      options[:api_token]          = repository.config['pivotal.api-token']
      options[:project_id]         = repository.config['pivotal.project-id']
      options[:integration_branch] = repository.config['pivotal.integration-branch']
      options[:fast_forward]       = repository.config['pivotal.fast-forward']
      options[:rebase]             = repository.config['pivotal.rebase']
      options[:full_name]          = repository.config['pivotal.full-name'] || repository.config['user.name']
      options[:verbose]            = repository.config['pivotal.verbose']
    end

    def parse_argv(*args)
      OptionParser.new do |opts|
        opts.banner = "Usage: git <feature|chore|bug> [options]"
        opts.on("-k", "--api-key=", "Pivotal Tracker API key") { |k| options[:api_token] = k }
        opts.on("-p", "--project-id=", "Pivotal Tracker project id") { |p| options[:project_id] = p }
        opts.on("-b", "--integration-branch=", "The branch to merge finished stories back down onto") { |b| options[:integration_branch] = b }
        opts.on("-f", "--fast-forward=", "Merge topic branch with fast forward") { |f| options[:fast_foward] = f }
        opts.on("-n", "--full-name=", "Your Pivotal Tracker full name") { |n| options[:full_name] = n }
        opts.on("-r", "--rebase=", "Fetch and rebase the integration branch before merging") { |r| options[:rebase] = r }
        opts.on("-v", "--verbose=", "Verbose command logging") { |v| options[:verbose] = v }
        opts.on_tail("-h", "--help", "This usage guide") { put opts.to_s; exit 0 }
      end.parse!(args)
    end

  end
end
