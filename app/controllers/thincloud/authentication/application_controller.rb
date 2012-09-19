module Thincloud::Authentication
  # Public: Primary controller settings and helpers for the engine.
  class ApplicationController < ActionController::Base
    layout "application"

  protected

    # Protected: The user that is currently logged in.
    #
    # This method is also available as a view helper.
    #
    # Returns: An instance of `User` or `nil`.
    def current_user
      return nil unless session[:uid].present?
      @current_user ||= User.find(session[:uid])
    end
    helper_method :current_user

    # Protected:  Determine if the current request has a logged in user.
    #
    # This method is also available as a view helper.
    #
    # Returns: Boolean.
    def logged_in?
      current_user.present?
    end
    helper_method :logged_in?

    # Protected: Require an authenticated user to perform an action.
    #
    # Use in a `before_filter`.
    #
    # Returns: Redirect if not logged in, otherwise `nil`.
    def authenticate!
      unless logged_in?
        redirect_to login_url, alert: "You must be logged in to continue."
      end
    end

    # Protected: Set the `current_user` to the provided `User` instance.
    #
    # user - An instance of `User` that has been authenticated.
    #
    # Returns: The `id` of the provided user.
    def login_as(user)
      reset_session  # avoid session fixation
      session[:uid] = user.id
    end

    # Protected: Clear the session of an authenticated user.
    #
    # Returns: A new empty session instance.
    def logout
      reset_session
    end

  end
end
