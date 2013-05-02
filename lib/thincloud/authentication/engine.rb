require "rails"
require "strong_parameters"

module Thincloud
  module Authentication

    # Public: Initialize the Rails engine
    class Engine < ::Rails::Engine
      isolate_namespace Thincloud::Authentication

      require "thincloud/authentication/configuration"

      initializer "thincloud.authentication.require_dependencies" do
        require_dependency "thincloud/authentication/authenticatable_controller"
        require_dependency "thincloud/authentication/identifiable_user"
      end

      initializer "thincloud.authentication.omniauth.middleware" do |app|
        require "omniauth"
        require "omniauth-identity"

        conf = Thincloud::Authentication.configuration || Configuration.new
        strategies = conf.providers.keys
        strategies.each do |strategy|
          lib = conf.providers[strategy][:require] || "omniauth-#{strategy}"
          require lib
        end

        app.middleware.use ::OmniAuth::Builder do
          # always provide the Identity strategy
          provider :identity, fields: [:email], model: Identity,
            on_failed_registration: RegistrationsController.action(:new)

          strategies.each do |strategy|
            provider strategy, ENV["#{strategy.to_s.upcase}_CONSUMER_KEY"],
              ENV["#{strategy.to_s.upcase}_CONSUMER_SECRET"],
              fields: conf.providers[strategy][:fields],
              scope: conf.providers[strategy][:scopes]
          end
        end
      end

      initializer "thincloud.authentication.omniauth.logger" do
        ::OmniAuth.config.logger = ::Rails.logger
      end

      initializer "thincloud.authentication.omniauth.failure_endpoint" do
        ::OmniAuth.config.on_failure = -> env do
          ::OmniAuth::FailureEndpoint.new(env).redirect_to_failure
        end
      end

      initializer "thincloud.authentication.omniauth.identity_redirects" do
        # override default omniauth-identity forms
        class ::OmniAuth::Strategies::Identity
          def registration_form
            redirect "/signup"
          end

          def request_phase
            redirect "/login"
          end
        end
      end

      initializer "thincloud.authentication.user" do
        config.to_prepare do
          ::User.send :include, Thincloud::Authentication::IdentifiableUser
        end
      end

      initializer "thincloud.authentication.action_controller" do
        config.to_prepare do
          ActionController::Base.send :include,
            Thincloud::Authentication::AuthenticatableController
        end
      end

      config.generators do |g|
        g.test_framework :mini_test, spec: true, fixture: false
      end
    end
  end
end
