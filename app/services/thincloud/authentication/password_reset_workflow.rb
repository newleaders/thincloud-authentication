module Thincloud::Authentication
  # Public: Execute the workflow steps to reset a password for an Identity
  class PasswordResetWorkflow
    def self.call(email)
      return unless identity = Identity.find_by_email(email)
      identity.generate_password_reset!
      PasswordsMailer.password_reset(identity.id).deliver
    end
  end
end
