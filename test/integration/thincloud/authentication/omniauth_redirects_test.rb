require "minitest_helper"

module Thincloud::Authentication
  class OmniauthRedirectsTest < MiniTest::Rails::ActionDispatch::IntegrationTest

    test "redirect away from /auth/identity" do
      get "/auth/identity"
      assert_response :redirect
      assert_redirected_to login_url
    end

    test "redirect away from /auth/identity/register" do
      get "/auth/identity/register"
      assert_response :redirect
      assert_redirected_to "/signup"  # `signup_url` unavailable?! :\
    end

    test "redirect to /auth/failure for bad credentials" do
      post "/auth/identity/callback", { auth_key: "invalid", password: "xxx" }
      assert_response :redirect
      assert_redirected_to auth_failure_url(message: "invalid_credentials", strategy: "identity")
    end
  end
end
