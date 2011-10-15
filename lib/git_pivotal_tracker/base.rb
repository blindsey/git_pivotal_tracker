module GitPivotalTracker
  class Base
    GIT_DIR = ENV['GIT_DIR'] || '.git'

    attr_reader :options, :repository

    def initialize(*args)
      directories = Dir.pwd.split(::File::SEPARATOR)
      begin
        break if File.directory?(File.join(directories, GIT_DIR))
      end while directories.pop

      raise "No #{GIT_DIR} directory found" if directories.empty?
      root = File.join(directories, GIT_DIR)
      @repository = Grit::Repo.new(root)

      new_hook_path = File.join(root, 'hooks', 'prepare-commit-msg')
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
      PivotalTracker::Client.use_ssl = options[:use_ssl]

      nil
    end

    protected

    def integration_branch
      options[:integration_branch] || current_branch_suffix || 'master'
    end
    
    def current_branch_suffix
      if current_branch_suffix =~ /.*-\d+?-(.*)/ and @repository.branches.any? { |branch| branch == $1 }
        $1
      end
    end

    def current_branch
      @current_branch ||= repository.head.name
    end

    def story_id
      if current_branch =~ /-(\d+)-/
        $1
      end
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
      options[:only_mine]          = repository.config['pivotal.only-mine']
      options[:include_rejected]   = repository.config['pivotal.include-rejected']
      options[:fast_forward]       = repository.config['pivotal.fast-forward']
      options[:rebase]             = repository.config['pivotal.rebase']
      options[:full_name]          = repository.config['pivotal.full-name'] || repository.config['user.name']
      options[:verbose]            = repository.config['pivotal.verbose']
      options[:use_ssl]            = repository.config['pivotal.use-ssl']
      options[:delete_branch]      = repository.config['pivotal.delete-branch']
    end

    def parse_argv(*args)
      OptionParser.new do |opts|
        opts.banner = "Usage: git <feature|chore|bug> [options]"
        opts.on("-t", "--api-token=", "Pivotal Tracker API key") { |k| options[:api_token] = k }
        opts.on("-p", "--project-id=", "Pivotal Tracker project id") { |p| options[:project_id] = p }
        opts.on("-b", "--integration-branch=", "The branch to merge finished stories back down onto") { |b| options[:integration_branch] = b }
        opts.on("-n", "--full-name=", "Your Pivotal Tracker full name") { |n| options[:full_name] = n }


        opts.on("-D", "--delete-branch", "Delete store branch after merging") { |d| options[:delete_branch] = d }
        opts.on("-I", "--include-rejected", "Include rejected stories as well as unstarted ones") { |i| options[:include_rejected] = i }
        opts.on("-O", "--only-mine", "Only include stories that are assigned to me") { |o| options[:only_mine] = o }
        opts.on("-F", "--fast-forward", "Merge topic branch with fast forward") { |f| options[:fast_forward] = f }
        opts.on("-S", "--use-ssl", "Use SSL for connection to Pivotal Tracker") { |s| options[:use_ssl] = s }
        opts.on("-R", "--rebase", "Fetch and rebase the integration branch before merging") { |r| options[:rebase] = r }
        opts.on("-V", "--verbose", "Verbose command logging") { |v| options[:verbose] = v }
        opts.on_tail("-h", "--help", "This usage guide") { put opts.to_s; exit 0 }
      end.parse!(args)
    end

  end
end
