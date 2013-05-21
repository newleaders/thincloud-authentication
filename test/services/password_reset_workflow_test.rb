require "minitest_helper"

module Thincloud::Authentication
  describe PasswordResetWorkflow do
    subject { PasswordResetWorkflow }

    it { subject.must_respond_to :call }

    describe "without a valid email" do
      before do
        Identity.expects(:find_by_email).with("foo@bar.com")
        Identity.any_instance.expects(:generate_password_reset!).never
        PasswordsMailer.expects(:password_reset).never
      end

      it { subject.call("foo@bar.com") }
    end

    describe "with a valid email" do
      let(:identity) do
        attrs = { email: "foo@bar.com", password_reset_token: "abc123" }
        Identity.new(attrs).tap { |i| i.id = 999 }
      end

      before do
        Identity.stubs(:find).with(999).returns(identity)
        Identity.stubs(:find_by_email).with("foo@bar.com").returns(identity)
        identity.expects(:generate_password_reset!)
      end

      it "sends an email with the reset token" do
        subject.call("foo@bar.com")
        email = ActionMailer::Base.deliveries.first
        email.to.must_include "foo@bar.com"
        email.subject.must_equal "Password Reset"
        email.body.encoded.must_match "/passwords/abc123/edit"
      end
    end

  end
end
