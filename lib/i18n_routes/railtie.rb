# frozen_string_literal: true

module I18nRoutes
  class Railtie < Rails::Railtie
    initializer "i18n_routes.controller" do
      ActiveSupport.on_load(:action_controller) { include I18nRoutes::Controller }
    end
  end
end
