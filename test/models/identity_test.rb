require "minitest_helper"

module Thincloud::Authentication
  describe Identity do
    let(:identity) { Identity.new }

    it { identity.provider.must_equal "identity" }
    it { identity.must_respond_to(:verification_token) }
    it { identity.verification_token.wont_be_nil }
    it { identity.verification_token.must_match /[\w\-]{22}/ }
    it { identity.must_respond_to(:verified_at) }

    describe "validates_presence_of" do
      before { identity.valid? }

      [:name, :email, :password].each do |field|
        it { identity.errors[field].must_include "can't be blank" }
      end
    end

    describe "validates_confirmation_of :password" do
      describe "matching passwords" do
        before do
          identity.password = identity.password_confirmation = "foo"
          identity.valid?
        end

        it { identity.errors[:password_confirmation].must_equal [] }
      end

      describe "non-matching passwords" do
        before do
          identity.password = "foo"
          identity.password_confirmation = "bar"
          identity.valid?
        end

        it { identity.errors[:password_confirmation].must_include "doesn't match Password" }
      end
    end

    describe "invalid values" do
      before do
        identity.email = "foo"
        identity.valid?
      end
      it { identity.errors[:email].must_include "is invalid" }
    end

    describe "valid values" do
      before do
        identity.email = "foo@blah.com"
        identity.valid?
      end
      it { identity.errors[:email].wont_include "is invalid" }
    end

    describe "self.find_omniauth(omniauth)" do
      describe "with valid uid" do
        let(:auth_hash) do
          OmniAuth::AuthHash.new(provider: "identity", uid: "123")
        end

        before do
          Identity.expects(:find_by_provider_and_uid).with("identity", "123")
        end

        it { Identity.find_omniauth(auth_hash) }
      end

      describe "with nil uid" do
        let(:auth_hash) do
          OmniAuth::AuthHash.new(provider: "identity", uid: nil)
        end

        before do
          Identity.expects(:find_by_provider_and_uid).never
        end

        it { Identity.find_omniauth(auth_hash).must_be_nil }
      end

      describe "with empty uid" do
        let(:auth_hash) do
          OmniAuth::AuthHash.new(provider: "identity", uid: "")
        end

        before do
          Identity.expects(:find_by_provider_and_uid).never
        end

        it { Identity.find_omniauth(auth_hash).must_be_nil }
      end
    end

    describe "self.verify!(token)" do
      it "raises an exception" do
        -> {
          Identity.verify!("invalid")
        }.must_raise(ActiveRecord::RecordNotFound)
      end

      describe "when found" do
        before do
          @identity = Identity.create!(name: "Test", email: "foo@bar.com",
                                       user_id: 123, password: "test",
                                       password_confirmation: "test")
          @identity.update_column :verification_token, "abc123"
        end

        it { Identity.verify!("abc123").must_equal @identity }
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

    describe "#generate_password_reset!" do
      before do
        @identity = Identity.create(
          user_id: 286,
          name: "Name",
          password: "password",
          password_confirmation: "password",
          email: "name@gmail.com"
        )
      end

      it "generates a token and records the time" do
        @identity.password_reset_token.must_be_nil
        @identity.password_reset_sent_at.must_be_nil
        @identity.generate_password_reset!
        @identity.password_reset_token.wont_be_nil
        @identity.password_reset_sent_at.wont_be_nil
      end
    end

    describe "#password_confirmation_required?" do
      describe "when password_required? is false" do
        before do
          identity.stubs(:password_required?).returns(false)
        end

        describe "when no password or confirmation is provided" do
          it { identity.password_confirmation_required?.must_equal false }
        end

        describe "when password is provided" do
          before do
            identity.password = "foo"
          end

          it { identity.password_confirmation_required?.must_equal true }
        end

        describe "when password_confirmation is provided" do
          before do
            identity.password_confirmation = "foo"
          end

          it { identity.password_confirmation_required?.must_equal true }
        end
      end

      describe "when password_required? is true" do
        before do
          identity.stubs(:password_required?).returns(true)
        end

        it { identity.password_confirmation_required?.must_equal true }
      end
    end
  end
end
