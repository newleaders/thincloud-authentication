module Thincloud
  module Authentication
    # Public: Initialize the Rails engine
    class Engine < ::Rails::Engine
      isolate_namespace Thincloud::Authentication

      initializer "thincloud.authentication.omniauth" do |app|
        require "omniauth"
        require "omniauth-identity"

        app.middleware.use ::OmniAuth::Builder do
          provider :identity, fields: [:email], model: Identity,
            on_failed_registration: RegistrationsController.action(:new)
        end
      end

      initializer "thincloud.authentication.action_controller" do
        ActionController::Base.send :include,
          Thincloud::Authentication::AuthenticatableController
      end

      config.generators do |g|
        g.test_framework :mini_test, spec: true, fixture: false
      end
    end
  end
end
