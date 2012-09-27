module HgVerify
  class RepoVerifier
    def initialize(options)
      @options = options
    end

    def verify
      validate_options
      pull_latest if @options[:pull_latest]
      ensure_latest if @options[:ensure_latest]
      info "Verifying a total of #{repos.length} repositories."
      repos.each { |url| verify_repo(url) }
      log_unmerged_repos if unmerged_repos.any?
      general "All repos have been merged." unless unmerged_repos.any?
    end

  private
    def hg(args)
      `hg #{args}`
    end

    def pull_latest
      info "Pulling latest changes from integration repo."
      hg pull
    end

    def ensure_latest
      info "Ensuring latest changes have been retrieved from server."
      output = hg incoming
      error "Fetch the latest changes from the server prior to running this script via hg pull #{@options[:integration_repo_url]}." unless output =~ /no changes found/
    end

    def validate_options
      required_options = [:integration_repo_url, :repo_config_path]

      required_options.each do |option|
        error "#{option} is required." unless @options[option]
      end

      error "Could not find repo config file at #{@options[:repo_config_path]}." unless File.exists?(File.expand_path(@options[:repo_config_path]))
      error "It is redundant to ensure latest if you are already pulling latest. Please specify one option or the other." if @options[:pull_latest] && @options[:ensure_latest]
    end

    def incoming(url=nil)
      url ? "incoming #{url}" : "incoming"
    end

    def pull(url=nil)
      url ? "pull #{url}" : "pull"
    end

    def repos
      @repos ||= repo_list
    end

    def unmerged_repos
      @unmerged_repos ||= []
    end

    def info(message)
      puts "[info] #{message}" if @options[:verbose]
    end

    def error(message)
      $stderr.print "[error] #{message}"
      exit
    end

    def general(message)
      puts "[general] #{message}"
    end

    def repo_list
      config_path = File.expand_path(@options[:repo_config_path])
      config = YAML.load_file(config_path)

      error "Your repo configuration is invalid. Please type hg_verify -h to see a sample configuration" unless config[:repositories]
      config[:repositories]
    end

    def verify_repo(url)
      info "Validating repository located at #{url} against #{@options[:integration_repo_url]}."
      output = hg incoming url

      if output =~ /no changes found/
        info "All changes from #{url} have been merged into #{@options[:integration_repo_url]}."
      else
        info "Unmerged repository detected."
        unmerged_changes_count = output.scan(/changeset.+\n?/m).length
        unmerged_repos << { url: url, unmerged_changes: unmerged_changes_count }
      end
    end

    def log_unmerged_repos
      if unmerged_repos.length == 1
        repository, has = "repository", "has" 
      else
        repository, has = "repositories", "have"
      end

      general "The following #{unmerged_repos.length} #{repository} #{has} not been fully merged."

      unmerged_repos.each do |repo_stat|
        general "Repository url: #{repo_stat[:url]} Unmerged changes: #{repo_stat[:unmerged_changes]}.\n"
      end
    end
  end
end
