require "minitest_helper"

module Thincloud::Authentication
  describe PasswordsController do
    describe "GET new" do
      before { get :new }

      it { assert_response :success }
      it { assert_template :new }
    end

    describe "POST create" do
      before do
        PasswordResetWorkflow.expects(:call).with("foo@bar.com")
        post :create, email: "foo@bar.com"
      end

      it { assert_response :redirect }
      it { assert_redirected_to login_url }
      it {
        flash[:notice].must_equal(
          "Email sent with password reset instructions."
        )
      }
    end

    describe "GET edit" do
      describe "with an invalid id" do
        it "raises an exception" do
          -> {
            get :edit, id: "invalid"
          }.must_raise(ActiveRecord::RecordNotFound)
        end
      end

      describe "with a valid id" do
        let(:identity) { Identity.new(password_reset_token: "abc123") }

        before do
          Identity.stubs(:find_by_password_reset_token!).with("abc123").returns(
            identity
          )
          get :edit, id: "abc123"
        end

        it { assert_response :success }
        it { assert_template :edit }
        it { assigns[:identity].must_equal identity }
      end
    end

    describe "PUT update" do
      before do
        attrs = {
          name: "test", email: "foo@bar.com", password: "test123",
          password_confirmation: "test123", password_reset_token: "abc123",
          password_reset_sent_at: 1.hour.ago, user_id: User.create.id
        }
        @identity = Identity.create!(attrs)
      end

      describe "with invalid identity attributes" do
        before do
          put :update, id: "abc123", identity: {
            password: "xxx1", password_confirmation: "xxx2"
          }
        end

        it { assert_response :success }
        it { assert_template :edit }
        it { assigns[:identity].must_equal @identity }
        it { assigns[:identity].errors[:password].wont_be_empty }
      end

      describe "with valid identity attributes" do
        before do
          put :update, id: "abc123", identity: {
            password: "p@ssw0rd1", password_confirmation: "p@ssw0rd1"
          }
        end

        it { assert_response :redirect }
        it { assert_redirected_to "/" }
      end
    end

  end
end
