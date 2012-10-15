require_dependency "thincloud/authentication/application_controller"

module Thincloud::Authentication
  # Public: Handle login/logout behavior.
  class SessionsController < ApplicationController
    before_filter :authenticate!, only: [:authenticated]

    def new
      if logged_in?
        redirect_to Thincloud::Authentication.configuration.after_login_path
      end
      @identity = Identity.new
    end

    def destroy
      logout
      redirect_to Thincloud::Authentication.configuration.after_logout_path,
        notice: "You have been logged out."
    end

    def authenticated
      # dummy method to test the :authenticate! before_filter
      render text: "Authenticated!"
    end
  end
end
