module Thincloud
  module Authentication

    module AuthenticatableController
      extend ActiveSupport::Concern

      included do
        helper_method :current_user
        helper_method :logged_in?
      end

    protected

      # Protected: The user that is currently logged in.
      #
      # This method is also available as a view helper.
      #
      # Returns: An instance of `User` or `nil`.
      def current_user
        return nil if session[:uid].blank?
        @current_user ||= User.find(session[:uid])
      end

      # Protected:  Determine if the current request has a logged in user.
      #
      # This method is also available as a view helper.
      #
      # Returns: Boolean.
      def logged_in?
        current_user.present?
      end

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

      # Protected: Provides the URL to redirect to after logging in.
      #
      # Returns: A string.
      def after_login_path
        main_app.root_url
      end

      # Protected: Provides the URL to redirect to after logging out.
      #
      # Returns: A string.
      def after_logout_path
        main_app.root_url
      end

      # Protected: Provides the URL to redirect to after registering.
      #
      # Returns: A string.
      def after_registration_path
        main_app.root_url
      end

    end

  end
end
