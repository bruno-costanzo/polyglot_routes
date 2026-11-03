# frozen_string_literal: true

module PolyglotRoutes
  # Included in every controller by the Railtie.
  module Controller
    def self.included(base)
      base.around_action :polyglot_routes_with_locale
      base.helper_method :switch_locale_path if base.respond_to?(:helper_method)
    end

    # The current page in another locale: switch_locale_path(:es)
    def switch_locale_path(locale)
      url_for(request.path_parameters.merge(locale: locale.to_s, only_path: true,
                                            params: request.query_parameters))
    end

    private

    def polyglot_routes_with_locale(&action)
      locale = request.path_parameters[:locale]
      locale ? I18n.with_locale(locale, &action) : yield
    end
  end
end
