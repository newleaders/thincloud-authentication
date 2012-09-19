require "minitest_helper"

module Thincloud::Authentication
  describe Identity do
    let(:identity) { Identity.new }

    it { identity.must validate_presence_of(:name) }
    it { identity.must validate_presence_of(:email) }
    it { identity.must allow_value("foo@bar.com").for(:email) }
    it { identity.wont allow_value("foo").for(:email) }
    it { identity.must validate_presence_of(:password_digest) }
    it { identity.must validate_confirmation_of(:password) }
    it { identity.must_respond_to(:verification_token) }
    it { identity.verification_token.wont_be_nil }
    it { identity.verification_token.must_match /[\w\-]{22}/ }
    it { identity.must_respond_to(:verified_at) }

    describe "self.find_omniauth(omniauth)" do
      let(:auth_hash) do
        OmniAuth::AuthHash.new(provider: "identity", uid: "123")
      end

      before do
        Identity.expects(:find_by_provider_and_uid).with("identity", "123")
      end

      it { Identity.find_omniauth(auth_hash) }
    end

    describe "self.verify!(token)" do
      it "raises an exception" do
        -> {
          Identity.verify!("invalid")
        }.must_raise(ActiveRecord::RecordNotFound)
      end

      describe "when found" do
        before do
          Identity.stubs(:find_by_verification_token!).with("token").returns(
            identity
          )
          Identity.any_instance.stubs(:save).returns(identity)
        end

        it { Identity.verify!("token").must_equal identity }
      end
    end

    describe "#verified?" do
      it { identity.verified?.must_equal false }

      describe "when true" do
        before do
          identity.verification_token = nil
          identity.verified_at = Time.now
        end

        it { identity.verified?.must_equal true }
      end
    end

    describe "#apply_omniauth(omniauth)" do
      let(:identity) { Identity.new }
      let(:auth_hash) do
        OmniAuth::AuthHash.new(
          provider: "linkedin", uid: "xxsdflkjsdf",
          credentials: Hashie::Mash.new, extra: Hashie::Mash.new,
          info: OmniAuth::AuthHash::InfoHash.new(
            email: "foo@bar.com", first_name: "New", last_name: "Name",
          )
        )
      end

      before { identity.apply_omniauth(auth_hash) }

      it { identity.name.must_equal "New Name" }
      it { identity.email.must_equal "foo@bar.com" }
      it { identity.provider.must_equal "linkedin" }
      it { identity.uid.must_equal "xxsdflkjsdf" }
    end
  end
end
