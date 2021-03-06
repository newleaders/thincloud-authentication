module Thincloud::Authentication
  # Public: Handle OmniAuth callbacks.
  class RegistrationsController < ApplicationController
    before_filter :extract_identity, only: :create

    layout Thincloud::Authentication.configuration.layout

    helper "thincloud/authentication/registrations"

    def new
      if current_user
        redirect_to after_login_path, notice: "You are already registered."
      end

      @identity = Identity.new
    end

    def create
      # identity exists
      if @identity.present?
        login_as @identity.user
        redirect_to after_login_path, notice: "You have been logged in."
      # new identity for current_user
      elsif current_user
        add_omniauth_identity_to_current_user
        redirect_to after_login_path, notice: "You have been logged in."
      # failed identity login
      elsif invalid_identity_credentials?
        redirect_to auth_failure_url message: "invalid_credentials",
                                     strategy: "identity"
      # create a new identity
      else
        @identity = create_identity_from_request
        render :new and return if @identity.errors.any?

        if omniauth
          login_as @identity.user
        else
          RegistrationsMailer.verification_token(@identity.id).deliver
          flash[:notice] = "Check your email to verify your registration."
        end
        redirect_to after_registration_path
      end
    end

    def verify
      identity = Identity.verify!(params[:token])
      login_as identity.user
      redirect_to after_verification_path,
        notice: "Thank you! Your registration has been verified."
    end

  private

    # Private: Accessor for OmniAuth environment.
    #
    # Returns: An instance of `OmniAuth::InfoHash` or `nil`.
    def omniauth
      request.env["omniauth.auth"]
    end

    # Private: Set an instance varible if an `Identity` if present.
    #
    # Returns: An instance of `Identity` or `nil`.
    def extract_identity
      @identity = Identity.find_omniauth(omniauth) if omniauth
    end

    # Private: Determine if the request is from an invalid Identity login.
    #
    # Returns: Boolean.
    def invalid_identity_credentials?
      params[:provider] == "identity" && params.has_key?(:auth_key)
    end

    # Private: Add a new identity to the `current_user` from OmniAuth.
    #
    # Returns: Boolean.
    def add_omniauth_identity_to_current_user
      current_user.identities.build.apply_omniauth(omniauth).save
    end

    # Private: Create a new identity from submitted params or OmniAuth.
    #
    # Returns: An instance of `Identity`.
    def create_identity_from_request
      # params[:identity] exists when creating a local identity provider
      Identity.new(identity_params).tap do |identity|
        identity.user = User.create
        # omniauth exists if coming from a 3rd party provider like LinkedIn
        identity.apply_omniauth(omniauth) if omniauth
        identity.save
      end
    end

    # Private: Provide strong_parameters support
    # :token, :auth_key, :provider,
    def identity_params
      keys = [
        :name, :email, :password,
        :password_confirmation, :verification_token
      ]

      params.require(:identity).permit(*keys)
    end
  end
end
