require_dependency "thincloud/authentication/application_controller"

module Thincloud::Authentication
  # Public: Handle OmniAuth callbacks.
  class RegistrationsController < ApplicationController
    def new
      @identity = Identity.new
    end

    def create
      # identity exists
      if omniauth && identity = Identity.find_omniauth(omniauth)
        login_as identity.user
        redirect_to root_url, notice: "You have been logged in."
      # new identity for current_user
      elsif current_user
        current_user.identities.build.apply_omniauth(omniauth).save
        redirect_to root_url, notice: "You have been logged in."
      # failed identity login
      elsif invalid_identity_credentials?
        redirect_to auth_failure_url message: "invalid_credentials",
                                     strategy: "identity"
      # create a new identity
      else
        # params[:identity] exists when creating a local identity provider
        @identity = Identity.new(params[:identity])
        @identity.user = User.create

        # omniauth exists if coming from a 3rd party provider like LinkedIn
        if omniauth
          @identity.apply_omniauth(omniauth)
        else
          flash[:alert] = "Welcome! Please check your email to verify your " <<
            "registration."
        end

        if @identity.save
          login_as @identity.user if omniauth
          redirect_to root_url
        else
          render :new
        end
      end
    end

    def verify
      identity = Identity.verify!(params[:token])
      login_as identity.user
      redirect_to root_url,
        notice: "Thank you! Your registration has been verified."
    end

  private

    # Private: Accessor for OmniAuth environment.
    #
    # Returns: An instance of `OmniAuth::InfoHash` or `nil`.
    def omniauth
      request.env["omniauth.auth"]
    end

    # Private: Determine if the request is from an invalid Identity login.
    #
    # Returns: Boolean.
    def invalid_identity_credentials?
      params[:provider] == "identity" && params.has_key?(:auth_key)
    end
  end
end
