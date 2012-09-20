module Thincloud::Authentication
  module IdentifiableUser
    extend ActiveSupport::Concern

    included do
      has_many :identities, class_name: "Thincloud::Authentication::Identity"
    end
  end
end
