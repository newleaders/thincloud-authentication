require "minitest_helper"

describe Thincloud::Authentication::Configuration do
  let(:config) { Thincloud::Authentication::Configuration.new }

  it { config.must_be_kind_of Thincloud::Authentication::Configuration }
  it { config.must_respond_to :layout }
  it { config.must_respond_to :layout= }
  it { config.must_respond_to :providers }
  it { config.must_respond_to :providers= }
  it { config.must_respond_to :mailer_sender }
  it { config.must_respond_to :mailer_sender= }

  describe "defaults" do
    it { config.layout.must_equal "application" }
    it { config.providers.must_equal Hash.new }
    it { config.mailer_sender.must_equal "app@example.com" }
  end

  describe "layout" do
    it { Thincloud::Authentication.configuration.layout.must_equal "application" }

    describe "with a custom layout" do
      before do
        Thincloud::Authentication.configure do |config|
          config.layout = "other"
        end
      end

      it { Thincloud::Authentication.configuration.layout.must_equal "other" }
    end
  end

  describe "provider" do
    before do
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

    it "options are assigned" do
      Thincloud::Authentication.configuration.providers.must_equal @providers_hash
    end
  end

end
