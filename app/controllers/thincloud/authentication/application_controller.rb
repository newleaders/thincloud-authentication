module Thincloud::Authentication
  # Public: Primary controller settings and helpers for the engine.
  class ApplicationController < ActionController::Base
    layout Thincloud::Authentication.configuration.layout
  end
end
