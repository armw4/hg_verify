module HgVerify
  class Cli
    class << self
      def run
        options = HgOptionParser.parse
        verifier = RepoVerifier.new(options)
        verifier.verify
      end
    end
  end
end
