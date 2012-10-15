module Thincloud
  module Authentication
    class << self
      attr_accessor :configuration
    end

    def self.configure
      self.configuration ||= Configuration.new
      yield configuration
    end

    # Public: Configuration options for the Thincloud::Authentication module
    class Configuration
      attr_accessor :providers, :layout, :mailer_sender, :after_login_path,
        :after_logout_path, :after_registration_path, :after_verification_path

      def initialize
        @providers = {}
        @layout = "application"
        @mailer_sender = "app@example.com"
        @after_login_path = "/"
        @after_logout_path = "/"
        @after_registration_path = "/"
        @after_verification_path = "/"
      end
    end
  end
end
