module Thincloud::Authentication
  module RegistrationsHelper

    def form_error_class_for(form, field)
      "error" if form.object.errors[field].present?
    end

  end
end
