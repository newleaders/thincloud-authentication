require "minitest_helper"

module Thincloud::Authentication
  describe InvitationsMailer do

    describe "#new_invitation" do
      let(:identity) do
        attrs = { email: "email@example.com", password_reset_token: "abc123" }
        Identity.new(attrs).tap{ |i| i.id = 999 }
      end

      let(:mail) { InvitationsMailer.new_invitation(identity.id) }

      before do
        Identity.stubs(:find).with(999).returns(identity)
      end

      it { mail.subject.must_equal "New account invitation" }
      it { mail.to.must_equal ["email@example.com"] }
      it { mail.from.must_equal ["app@example.com"] }
      it { mail.body.encoded.must_match "To accept the invitation and choose a password, click the URL below." }
      it { mail.body.encoded.must_match "/invitations/abc123" }
    end
  end
end
