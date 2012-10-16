module Thincloud::Authentication
  # Public: Handle login/logout behavior.
  class SessionsController < ApplicationController
    before_filter :authenticate!, only: [:authenticated]

    layout Thincloud::Authentication.configuration.layout

    helper "thincloud/authentication/registrations"

    def new
      redirect_to after_login_path if logged_in?
      @identity = Identity.new
    end

    def destroy
      logout
      redirect_to after_logout_path, notice: "You have been logged out."
    end

    def authenticated
      # dummy method to test the :authenticate! before_filter
      render text: "Authenticated!"
    end
  end
end
