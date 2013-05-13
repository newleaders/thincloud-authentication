module Thincloud::Authentication
  # Public: Email methods for sending invitations
  class InvitationsMailer < ActionMailer::Base
    default from: Thincloud::Authentication.configuration.mailer_sender

    # New invitation notification
    def new_invitation(identity_id)
      @identity = Identity.find(identity_id)
      mail to: @identity.email, subject: "New account invitation"
    end
  end
end
