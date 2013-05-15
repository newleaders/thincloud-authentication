require "minitest_helper"

module Thincloud::Authentication
  describe CreateInvitationForUser do
    subject { CreateInvitationForUser }

    it { subject.must_respond_to :call }

    let(:user) { User.new.tap{ |u| u.id = 999 } }

    describe "without valid identity parameters" do
      before do
        Identity.any_instance.expects(:generate_password_token!).never
        InvitationsMailer.expects(:new_invitation).never
      end

      it { subject.call(user, {}).must_equal false }
    end

    describe "with valid identity parameters" do
      before do
        @identity_count = Identity.count
      end

      it "creates an identity and sends an email with the invitation url" do
        subject.call(user, name: "test", email: "foo@bar.com").must_equal true
        Identity.count.must_equal (@identity_count + 1)
        email = ActionMailer::Base.deliveries.first
        email.to.must_include "foo@bar.com"
        email.subject.must_equal "New account invitation"
        email.body.encoded.must_match %r(/invitations/[\w\-]+{10,})
      end
    end

  end
end
