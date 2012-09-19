module Thincloud
  module Authentication
    # Public: Initialize the Rails engine
    class Engine < ::Rails::Engine
      isolate_namespace Thincloud::Authentication

      initializer "thincloud.authentication.omniauth" do |app|
        require "omniauth"
        require "omniauth-identity"
      end

      config.generators do |g|
        g.test_framework :mini_test, spec: true, fixture: false
      end
    end
  end
end
