module Thincloud::Authentication
  # Public: Execute the workflow steps to reset a password for an Identity
  class UpdateIdentityPassword

    def self.call(identity, params)
      identity.password = params[:password]
      identity.password_confirmation = params[:password_confirmation]
      identity.password_reset_token = nil
      identity.password_reset_sent_at = nil
      identity.save!
    rescue ActiveRecord::RecordInvalid
      identity.reload
      false
    end

  end
end
