module Thincloud
  module Authentication
    class User < ActiveRecord::Base
      has_many :identities, class_name: "Thincloud::Authentication::Identity"
      self.table_name = "users"
    end
  end
end
