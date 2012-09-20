require_dependency "thincloud/authentication/application_controller"

module Thincloud::Authentication
  # Public: Handle login/logout behavior.
  class SessionsController < ApplicationController
    before_filter :authenticate!, only: [:authenticated]

    def new
      redirect_to main_app.root_url if logged_in?
      @identity = Identity.new
    end

    def destroy
      logout
      redirect_to main_app.root_url, notice: "You have been logged out."
    end

    def authenticated
      # dummy method to test the :authenticate! before_filter
      render text: "Authenticated!"
    end
  end
end
