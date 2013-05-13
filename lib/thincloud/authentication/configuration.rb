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
      attr_accessor :layout, :providers, :mailer_sender, :cookie_options

      def initialize
        @layout = "application"
        @providers = {}
        @mailer_sender = "app@example.com"
        @cookie_options = {}
      end
    end
  end
end
