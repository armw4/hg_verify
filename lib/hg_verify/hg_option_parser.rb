module HgVerify
  class HgOptionParser
    class << self
      def parse(args=ARGV)
        options = {}
        options[:integration_repo_url] = nil
        options[:repo_config_path] = nil
        options[:verbose] = false
        options[:ensure_latest] = false
        options[:pull_latest] = false

        option_parser = OptionParser.new do |opts|
          opts.banner = "Usage: cd <integration-repo-path> \nhgverify [options]"
          opts.separator  ""
          opts.separator "Specific options:"

          opts.on("-i", "--integration-repo-url URL", "The URL of the integration repository") do |url|
            options[:integration_repo_url] = url
          end

          opts.on("-s", "--silver-repos-config-path FILE.yml", "The location of the silver repos to be verified; specified in YAML format.",
                    ":repositories:",
                      "  - https://vcs.domain.com/Core12/DevRepo1",
                      "  - https://vcs.domain.com/Core12/DevRepo2",
                      "  - https://vcs.domain.com/Core12/DevRepo3",
                      "  - https://vcs.domain.com/Core12/DevRepo4",) do |repo_path|
                        options[:repo_config_path] = repo_path
          end

          opts.on("-e", "--ensure-latest", "Ensure the latest changes have been fetched from the integration repository pre-verification.",
                    "You should only enable this option if mercurial does not require you to manually enter your",
                    "credentials when communicating with the server. Otherwise the script would block due to reads from STDIN",
                    "via mercurial (.i.e. username/password prompt). Forking the current process would most likely resolve this.",
                    "issue as we'd take on the identity of the mercurial process thus allowing the user to provide their credentials.",
                    "This should be fine if the script is executed on the server that the repos reside on as authentication would be supressed.") do
            options[:ensure_latest] = true
          end

          opts.on("-p", "--pull-latest", "Pulls the latest changes from the integration repository pre-verification.",
                     "You should only enable this option if mercurial does not require you to manually enter your",
                    "credentials when communicating with the server. Otherwise the script would block due to reads from STDIN",
                    "via mercurial (.i.e. username/password prompt). Forking the current process would most likely resolve this.",
                    "This should be fine if the script is executed on the server that the repos reside on as authentication would be supressed.") do
            options[:pull_latest] = true
          end

          opts.on("-v", "--verbose", "Run verbosely") do
            options[:verbose] = true
          end

          opts.on_tail("-h", "--help", "Available options") do
            puts opts
            exit
          end
        end

        option_parser.parse!(args)
        options
      end
    end
  end
end
