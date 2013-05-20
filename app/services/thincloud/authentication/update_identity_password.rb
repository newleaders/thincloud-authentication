module Thincloud::Authentication
  # Public: Execute the workflow steps to reset a password for an Identity
  class UpdateIdentityPassword

    def self.call(identity, params)
      identity.password = params[:password]
      identity.password_confirmation = params[:password_confirmation]
      identity.save!
      identity.clear_password_reset!
    rescue ActiveRecord::RecordInvalid
      identity.reload
      false
    end

  end
end
