# frozen_string_literal: true

module I18nRoutes
  # Prepended into ActionDispatch::Routing::Mapper.
  module Mapper
    # Draws every route in the block once per locale.
    #
    #   localized do
    #     resources :products
    #   end
    def localized(locales: I18nRoutes.locales)
      locales = locales.map(&:to_s)
      unknown = locales - I18nRoutes.locales
      raise ArgumentError, "Unknown locales for localized: #{unknown.join(", ")}" if unknown.any?

      previous = @i18n_routes_locales
      @i18n_routes_locales = locales
      yield
    ensure
      @i18n_routes_locales = previous
    end

    private

    def add_route(*args)
      return super if @i18n_routes_locales.nil? || @i18n_routes_locale

      @i18n_routes_locales.each do |locale|
        @i18n_routes_locale = locale
        @scope = @scope.new(defaults: (@scope[:defaults] || {}).merge(locale: locale))
        super
      ensure
        @scope = @scope.parent
        @i18n_routes_locale = nil
      end

      define_i18n_routes_helpers
    end

    def path_for_action(action, path)
      result = super
      @i18n_routes_locale ? I18nRoutes.translate_path(result, @i18n_routes_locale) : result
    end

    def name_for_action(as, action)
      name = super
      return name unless @i18n_routes_locale && name

      localized = "#{name}_#{@i18n_routes_locale}"
      return if as == ActionDispatch::Routing::Mapper::DEFAULT && has_named_route?(localized)

      @i18n_routes_last_name = name
      localized
    end

    # Defines `products_path` / `products_url` that call the helper for I18n.locale.
    def define_i18n_routes_helpers
      name = @i18n_routes_last_name
      @i18n_routes_last_name = nil
      return unless name

      { "path" => @set.named_routes.path_helpers_module,
        "url" => @set.named_routes.url_helpers_module }.each do |kind, helpers|
        helpers.define_method("#{name}_#{kind}") do |*args|
          I18nRoutes.call_helper(self, name, kind, args)
        end
      end
    end
  end
end

ActionDispatch::Routing::Mapper.prepend(I18nRoutes::Mapper)
