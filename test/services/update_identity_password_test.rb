require "minitest_helper"

module Thincloud::Authentication
  describe UpdateIdentityPassword do
    subject { UpdateIdentityPassword }

    it { subject.must_respond_to :call }

    before do
      attrs = {
        name: "test", email: "foo@bar.com", user_id: User.create.id,
        password: "test123", password_confirmation: "test123",
        password_reset_token: "abc123", password_reset_sent_at: 1.hour.ago
      }
      @identity = Identity.create!(attrs)
    end

    describe "with an invalid password combination" do
      it "does not update the identity" do
        password_params = { password: "foo", password_confirmation: "bar" }
        subject.call(@identity, password_params).must_equal false
        @identity.errors[:password].wont_be_empty
        @identity.reload.password_reset_token.wont_be_nil
        @identity.password_reset_sent_at.wont_be_nil
      end
    end

    describe "with a valid password combination" do
      it "does updates the identity" do
        password_params = {
          password: "s3kr1t123", password_confirmation: "s3kr1t123"
        }
        subject.call(@identity, password_params).must_equal true
        @identity.errors[:password].must_be_empty
        @identity.reload.password_reset_token.must_be_nil
        @identity.password_reset_sent_at.must_be_nil
      end
    end
  end
end
