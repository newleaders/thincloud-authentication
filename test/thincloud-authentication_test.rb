require "minitest_helper"

class Thincloud::AuthenticationTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, Thincloud::Authentication
  end
end
