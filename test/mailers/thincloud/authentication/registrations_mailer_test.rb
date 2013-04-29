require "minitest_helper"

module Thincloud::Authentication
  describe RegistrationsMailer do

    describe "#verification_token" do
      let(:identity) {
        Identity.create!(
          name: "Name", email: "email@example.com", user_id: 123,
          password: "test123", password_confirmation: "test123"
        )
      }
      let(:mail) { RegistrationsMailer.verification_token(identity.id) }

      it { mail.subject.must_equal "Identity Verification" }
      it { mail.to.must_equal ["email@example.com"] }
      it { mail.from.must_equal ["app@example.com"] }
      it { mail.body.encoded.must_match "Welcome #{identity.email}!" }
      it { mail.body.encoded.must_match "You can verify your account through the link below:" }
      it { mail.body.encoded.must_match "/verify/#{identity.verification_token}" }
    end
  end
end
