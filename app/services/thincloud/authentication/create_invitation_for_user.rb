module Thincloud::Authentication
  # Public: Execute the workflow steps to create and identity and send an
  # invitation email
  class CreateInvitationForUser

    def self.call(user, params)
      identity = Identity.create!(user: user, name: params[:name],
                                  email: params[:email], password_digest: 0)
      Identity.verify!(identity.verification_token)
      identity.generate_password_token!
      InvitationsMailer.new_invitation(identity.id).deliver
      true
    rescue ActiveRecord::RecordInvalid
      false
    end

  end
end
