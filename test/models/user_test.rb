require "minitest_helper"

module Thincloud::Authentication
  describe User do
    before do
      @user = User.new
    end
  
    it "must be valid" do
      @user.valid?.must_equal true
    end
  end
end
