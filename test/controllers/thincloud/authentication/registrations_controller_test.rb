require "minitest_helper"

module Thincloud::Authentication
  describe RegistrationsController do
    describe "GET new" do
      before { get :new }

      it { assert_response :success }
      it { assigns[:identity].wont_be_nil }
    end

    describe "POST create" do
      describe "with errors" do
        before { post :create, identity: { email: "" } }

        it { assert_response :success }
        it { assert_template :new }
        it { assigns[:identity].wont_be_nil }
        it { assigns[:identity].errors.any?.must_equal true }
      end

      describe "find an existing Identity" do
        let(:user) { User.create }
        let(:identity) { id = Identity.new; id.user = user; id }
        let(:auth_hash) do
          OmniAuth::AuthHash.new(
            credentials: Hashie::Mash.new, extra: Hashie::Mash.new,
            info: OmniAuth::AuthHash::InfoHash.new(
              email: "foo@bar.com", name: "Foo"
            ),
            provider: "identity", uid: 123
          )
        end

        before do
          RegistrationsController.any_instance.stubs(:omniauth).returns(
            auth_hash
          )
          Identity.stubs(:find_omniauth).with(auth_hash).returns(identity)
          User.stubs(:find).with(123).returns(user)
          post :create
        end

        it { session[:uid].wont_be_nil }
        it { assert_response :redirect }
        it { assert_redirected_to "/" }
        it { flash[:notice].must_equal "You have been logged in." }
      end

      describe "add an Identity to current_user" do
        let(:user) { User.create }
        let(:identity) do
          attrs = {
            name: "foo", email: "foo@bar", password: "foo",
            password_confirmation: "foo"
          }
          Identity.new(attrs).tap do |identity|
            identity.user = user
            identity.save
          end
        end

        let(:auth_hash) do
          OmniAuth::AuthHash.new(
            credentials: Hashie::Mash.new, extra: Hashie::Mash.new,
            info: OmniAuth::AuthHash::InfoHash.new(
              email: "foo2@bar2.com", first_name: "New", last_name: "Name",
            ),
            provider: "linkedin", uid: "xxsdflkjsdf"
          )
        end

        before do
          RegistrationsController.any_instance.stubs(:omniauth).returns(
            auth_hash
          )
          RegistrationsController.any_instance.stubs(:current_user).returns(user)
          identity
          post :create
        end

        it { assert_response :redirect }
        it { assert_redirected_to "/" }
        it { flash[:notice].must_equal "You have been logged in." }

        it { user.identities.count.must_equal 2 }
        it { user.identities.last.provider.must_equal "linkedin" }
        it { user.identities.last.read_attribute(:uid).must_equal "xxsdflkjsdf" }
        it { user.identities.last.name.must_equal "New Name" }
        it { user.identities.last.email.must_equal "foo2@bar2.com" }
      end

      describe "invalid Identity credentials" do
        before do
          post :create, { auth_key: "invalid@email", provider: "identity" }
        end

        it { assert_response :redirect }
        it { assert_redirected_to auth_failure_url(message: "invalid_credentials", strategy: "identity") }
      end

      describe "create a new Identity" do
        describe "with 'identity' provider" do
          before do
            post :create, identity: {
              name: "Foo", email: "foo@bar.com",
              password: "test", password_confirmation: "test"
            }
          end

          it { assert_response :redirect }
          it { assert_redirected_to "/" }
          it { session[:uid].must_be_nil }
          it { flash[:notice].must_equal "Check your email to verify your registration." }
          it { User.count.must_equal 1 }
          it { Identity.count.must_equal 1 }
          it { ActionMailer::Base.deliveries.map(&:to).flatten.must_include "foo@bar.com" }
          it { ActionMailer::Base.deliveries.map(&:subject).must_include "Identity Verification" }
        end

        describe "with 'linkedin' provider" do
          let(:auth_hash) do
            OmniAuth::AuthHash.new(
              credentials: Hashie::Mash.new, extra: Hashie::Mash.new,
              info: OmniAuth::AuthHash::InfoHash.new(
                email: "foo2@bar2.com", first_name: "New", last_name: "Name",
              ),
              provider: "linkedin", uid: "xxsdflkjsdf"
            )
          end

          before do
            RegistrationsController.any_instance.stubs(:omniauth).returns(
              auth_hash
            )
            post :create, identity: { email: "foo2@bar2.com" }
          end

          it { assert_response :redirect }
          it { assert_redirected_to "/" }
          it { session[:uid].must_equal assigns[:identity].user.id }
          it { flash[:alert].must_be_nil }
          it { User.count.must_equal 1 }
          it { Identity.count.must_equal 1 }
        end
      end
    end

    describe "GET verify" do
      describe "invalid token" do
        it "raises an exception" do
          -> {
            get :verify, token: "invalid"
          }.must_raise(ActiveRecord::RecordNotFound)
        end
      end

      describe "valid token" do
        let(:user) { User.create }
        let(:identity) { id = Identity.new; id.user = user; id }

        before do
          Identity.stubs(:verify!).with("token").returns(identity)
          get :verify, token: "token"
        end

        it { assert_response :redirect }
        it { assert_redirected_to "/" }
        it { flash[:notice].must_equal "Thank you! Your registration has been verified." }
      end
    end
  end
end
