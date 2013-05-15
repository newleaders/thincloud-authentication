module Thincloud::Authentication
  # Public: Handle password reset management
  class PasswordsController < ApplicationController

    before_filter :find_identity, only: [:edit, :update]

    layout Thincloud::Authentication.configuration.layout

    def new
      render
    end

    def create
      PasswordResetWorkflow.call(params[:email])
      redirect_to login_url,
        notice: "Email sent with password reset instructions."
    end

    def edit
      render
    end

    def update
      if UpdateIdentityPassword.call(@identity, identity_params)
        login_as @identity.user
        redirect_to after_password_update_path
      else
        flash.now[:alert] = "Unable to update password. Please try again."
        render :edit
      end
    end


    private

    def find_identity
      @identity = Identity.find_by_password_reset_token!(params[:id])
    end

    def identity_params
      params.require(:identity).permit(:password, :password_confirmation)
    end

  end
end
