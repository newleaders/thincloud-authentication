class AddPasswordResetTokenAndPasswordResetSentAtToIdentities < ActiveRecord::Migration
  def change
    add_column :thincloud_authentication_identities, :password_reset_token,
      :string, default: nil
    add_column :thincloud_authentication_identities, :password_reset_sent_at,
      :datetime, default: nil
  end
end
