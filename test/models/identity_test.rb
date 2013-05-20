require "minitest_helper"

module Thincloud::Authentication
  describe Identity do
    let(:identity) { Identity.new }

    it { identity.must validate_presence_of(:name) }
    it { identity.must validate_presence_of(:email) }
    it { identity.must allow_value("foo@bar.com").for(:email) }
    it { identity.wont allow_value("foo").for(:email) }
    it { identity.must validate_presence_of(:password_digest) }
    it { identity.must_respond_to(:verification_token) }
    it { identity.verification_token.wont_be_nil }
    it { identity.verification_token.must_match /[\w\-]{22}/ }
    it { identity.must_respond_to(:verified_at) }

    describe "validations for password fields" do
      describe "when password is required" do
        before { identity.stubs(:password_required?).returns(true) }

        it { identity.must validate_presence_of(:password) }
        it { identity.must validate_confirmation_of(:password) }
      end
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
        Identity.any_instance.stubs(:save!)
      end

      it "generates a token and records the time" do
        identity.password_reset_token.must_be_nil
        identity.password_reset_sent_at.must_be_nil
        identity.generate_password_reset!
        identity.password_reset_token.wont_be_nil
        identity.password_reset_sent_at.wont_be_nil
      end
    end

    describe "#password_required?" do
      describe "when provider is identity" do
        before { identity.expects(:identity_provider?).returns(true) }

        describe "with password provided" do
          before { identity.password = "abc123" }
          it     { identity.password_required?.must_equal true }
        end

        describe "with password confirmation provided" do
          before { identity.password_confirmation = "abc123" }
          it     { identity.password_required?.must_equal true }
        end

        describe "without password or confirmation on persisted identity" do
          before { identity.stubs(:new_record?).returns(false) }
          it { identity.password_required?.must_equal false }
        end
      end

      describe "when provider is not identity" do
        before { identity.expects(:identity_provider?).returns(false) }
        it     { identity.password_required?.must_equal false }
      end
    end


    describe "resetting password manually" do
      before do
        identity.password = identity.password_confirmation = "abc123"
        identity.save
      end

      it { identity.authenticate("abc123").must_equal identity }

      describe "after changing non-password values" do
        before do
          identity.name = "foobar"
          identity.password = identity.password_confirmation = ""
          identity.save
        end

        it { identity.name.must_equal "foobar" }

        it "does not change the password" do
          identity.authenticate("abc123").must_equal identity
        end
      end
    end
  end
end
