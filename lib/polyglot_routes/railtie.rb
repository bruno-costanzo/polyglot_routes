# frozen_string_literal: true

module PolyglotRoutes
  class Railtie < Rails::Railtie
    initializer "polyglot_routes.controller" do
      ActiveSupport.on_load(:action_controller) { include PolyglotRoutes::Controller }
    end
  end
end
