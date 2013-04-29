module Thincloud::Authentication
  # Public: Email methods for Registration events
  class RegistrationsMailer < ActionMailer::Base
    default from: Thincloud::Authentication.configuration.mailer_sender

    # New registration verification token
    def verification_token(identity_id)
      @identity = Identity.find(identity_id)
      mail to: @identity.email, subject: "Identity Verification"
    end
  end
end
