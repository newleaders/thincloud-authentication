require "minitest_helper"

class Thincloud::Authentication::ConfigureTest < ActiveSupport::TestCase
  setup do
    Thincloud::Authentication.configure do |config|
      config.providers[:linkedin] = {
        scopes: "r_emailaddress r_basicprofile",
        fields: ["id", "email-address", "first-name", "last-name", "headline",
                 "industry", "picture-url", "location", "public-profile-url"]
      }
    end

    @providers_hash = {
      linkedin: {
        scopes: "r_emailaddress r_basicprofile",
        fields: ["id", "email-address", "first-name", "last-name", "headline",
                 "industry", "picture-url", "location", "public-profile-url"]
      }
    }
  end

  test "options are assigned" do
    assert_equal @providers_hash, Thincloud::Authentication.configuration.providers
  end
end
