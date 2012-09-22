module Thincloud
  module Authentication
    # Public: Initialize the Rails engine
    class Engine < ::Rails::Engine
      isolate_namespace Thincloud::Authentication

      initializer "thincloud.authentication.omniauth.middleware" do |app|
        require "omniauth"
        require "omniauth-identity"

        config = Thincloud::Authentication.configuration || Configuration.new
        strategies = config.providers.keys
        strategies.each { |strategy| require "omniauth-#{strategy}" }

        app.middleware.use ::OmniAuth::Builder do

          # always provide the Identity strategy
          provider :identity, fields: [:email], model: Identity,
            on_failed_registration: RegistrationsController.action(:new)

          strategies.each do |strategy|
            provider strategy, ENV["#{strategy.to_s.upcase}_CONSUMER_KEY"],
              ENV["#{strategy.to_s.upcase}_CONSUMER_SECRET"],
              fields: config.providers[strategy][:fields],
              scope: config.providers[strategy][:scopes]
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
        ::User.send :include, Thincloud::Authentication::IdentifiableUser
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
