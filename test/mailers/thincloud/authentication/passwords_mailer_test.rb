require "minitest_helper"

module Thincloud::Authentication
  describe PasswordsMailer do

    describe "#password_reset" do
      let(:identity) do
        attrs = { email: "email@example.com", password_reset_token: "abc123" }
        Identity.new(attrs).tap{ |i| i.id = 999 }
      end

      let(:mail) { PasswordsMailer.password_reset(identity.id) }

      before do
        Identity.stubs(:find).with(999).returns(identity)
      end

      it { mail.subject.must_equal "Password Reset" }
      it { mail.to.must_equal ["email@example.com"] }
      it { mail.from.must_equal ["app@example.com"] }
      it { mail.body.encoded.must_match "To reset your password, click the URL below." }
      it { mail.body.encoded.must_match "/passwords/abc123/edit" }
    end
  end
end
