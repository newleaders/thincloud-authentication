module Thincloud::Authentication
  # Public: Email methods for Password events
  class PasswordsMailer < ActionMailer::Base
    default from: Thincloud::Authentication.configuration.mailer_sender

    # Password reset notification
    def password_reset(identity_id)
      @identity = Identity.find(identity_id)
      mail to: @identity.email, subject: "Password Reset"
    end
  end
end
