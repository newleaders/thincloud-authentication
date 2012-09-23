module Thincloud::Authentication
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield configuration
  end

  # Public: Configuration options for the Thincloud::Authentication module
  class Configuration
    attr_accessor :providers, :mailer_sender

    def initialize
      @providers = {}
      @mailer_sender = "app@example.com"
    end
  end
end
