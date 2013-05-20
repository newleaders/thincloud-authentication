module Thincloud::Authentication
  # Public: This class represents a User identity (name, email, login provider)
  class Identity < ::OmniAuth::Identity::Models::ActiveRecord
    include ActiveModel::ForbiddenAttributesProtection  # strong_parameters

    belongs_to :user

    validates :name, presence: true
    validates :email, presence: true, uniqueness: true, format: /@/
    validates :password, presence: { if: :password_required? },
      confirmation: { if: :password_required? }

    # Ensure that a `verification_token` exists for new records.
    after_initialize do
      self.verification_token = SecureRandom.urlsafe_base64 if new_record?
    end

    # Only validate password if the 'provider' is 'identity'.
    before_validation do
      self.password_digest = 0 unless identity_provider?
    end

    # Public: Use a helpful attribute name when displaying errors.
    def self.human_attribute_name(attr, options={})
      attr == :password_digest ? "Password" : super
    end

    # Public: Find an `Identity` by OmniAuth parameters.
    #
    # omniauth - An instance of `OmniAuth::AuthHash`
    #
    # Returns: An instance of `Identity` or `nil`.
    def self.find_omniauth(omniauth)
      if omniauth["uid"].present?
        find_by_provider_and_uid omniauth["provider"], omniauth["uid"]
      end
    end

    # Public: Mark the `Identity` as having been verified.
    #
    # token - A String containing the `verification_token` to look up.
    #
    # Returns: An instance of the found `Identity`.
    # Raises: ActiveRecord::RecordNotFound if the `token` cannot be retrieved.
    #         ActiveRecord::RecordInvalid if the record cannot be saved.
    def self.verify!(token)
      find_by_verification_token!(token).tap do |identity|
        # ensure 'uid' exists, needed for 'identity' provider
        identity.uid = identity.id if identity.uid.blank?
        identity.verification_token = nil
        identity.verified_at = Time.zone.now
        identity.save!
      end
    end

    # Public: Shim to overcome odd behavior seen during testing with SQLite
    def uid
      read_attribute :uid
    end

    # Public: Indicate if the `Identity` has been verified.
    #
    # Returns: Boolean.
    def verified?
      verification_token.blank? && verified_at.present?
    end

    # Public: Apply attributes returned from OmniAuth.
    #
    # omniauth - An instance of `OmniAuth::AuthHash`.
    def apply_omniauth(omniauth)
      info = omniauth["info"]

      user_name = %Q(#{info["first_name"]} #{info["last_name"]})
      user_name.gsub!(/\s+/, " ").strip!

      self.provider = omniauth["provider"]
      self.uid      = omniauth["uid"]
      self.name     = user_name if self.name.blank?
      self.email    = info["email"] if info["email"] && self.email.blank?
      self
    end

    # Public: Generate a password reset token
    #
    # Returns: true
    #
    # Raises: ActiveRecord::RecordInvalid
    def generate_password_reset!
      self.password_reset_token = SecureRandom.urlsafe_base64
      self.password_reset_sent_at = Time.zone.now
      save!
    end

    # Public: Clear password reset fields, reset password_required? requirement
    #
    # Returns: true
    #
    # Raises: ActiveRecord::RecordInvalid
    def clear_password_reset!
      self.password_reset_token = nil
      self.password_reset_sent_at = nil
      save!
    end

    # Public: Determine if the provider is 'identity'
    #
    # Returns: true or false
    def identity_provider?
      provider == "identity"
    end

    # Public: Determine if the password must be provided
    #
    # Returns: true or false
    def password_required?
      identity_provider? && (new_record? || password_reset_token.present?)
    end
  end
end
