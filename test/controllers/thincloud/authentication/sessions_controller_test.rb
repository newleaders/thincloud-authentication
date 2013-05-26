require "minitest_helper"

module Thincloud::Authentication
  describe SessionsController do
    describe "GET new" do

      describe "when not logged in" do
        before { get :new }

        it { assert_response :success }
        it { assert_template :new }
        it { cookies.signed[:uid].must_be_nil }
      end

      describe "when not logged in and request.referer contains a path" do

        it "sets the session[:return_to] to the proper path" do
          request.expects(:referer).times(2).returns("http://test_path.com")
          get :new
          session[:return_to].must_equal "http://test_path.com"
        end
      end

      describe "when logged in" do
        before do
          SessionsController.any_instance.stubs(:logged_in?).returns(true)
          get :new
        end

        it { assert_redirected_to "/" }
      end

    end

    describe "DELETE destroy" do
      before { delete :destroy }

      it { assert_redirected_to "/" }
      it { flash[:notice].must_equal "You have been logged out." }
      it { cookies.signed[:uid].must_be_nil }
    end

    describe "GET authenticated" do
      describe "not logged in" do
        before { get :authenticated  }

        it { assert_response :redirect }
        it { assert_redirected_to login_url }
        it { flash[:alert].must_equal "You must be logged in to continue." }
      end

      describe "logged in" do
        before do
          User.stubs(:find).with(123).returns(User.new)
          cookies.signed[:uid] = 123
          get :authenticated
        end

        it { assert_response :success }
      end
    end
  end
end
