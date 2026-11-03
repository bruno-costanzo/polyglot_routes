# frozen_string_literal: true

module PolyglotRoutes
  # Prepended into ActionDispatch::Routing::Mapper.
  module Mapper
    # Draws every route in the block once per locale.
    #
    #   localized do
    #     resources :products
    #   end
    def localized(locales: PolyglotRoutes.locales)
      locales = locales.map(&:to_s)
      unknown = locales - PolyglotRoutes.locales
      raise ArgumentError, "Unknown locales for localized: #{unknown.join(", ")}" if unknown.any?

      previous = @polyglot_routes_locales
      @polyglot_routes_locales = locales
      yield
    ensure
      @polyglot_routes_locales = previous
    end

    private

    def add_route(*args)
      return super if @polyglot_routes_locales.nil? || @polyglot_routes_locale

      @polyglot_routes_locales.each do |locale|
        @polyglot_routes_locale = locale
        @scope = @scope.new(defaults: (@scope[:defaults] || {}).merge(locale: locale))
        super
      ensure
        @scope = @scope.parent
        @polyglot_routes_locale = nil
      end

      define_polyglot_routes_helpers
    end

    def path_for_action(action, path)
      result = super
      @polyglot_routes_locale ? PolyglotRoutes.translate_path(result, @polyglot_routes_locale) : result
    end

    def name_for_action(as, action)
      name = super
      return name unless @polyglot_routes_locale && name

      localized = "#{name}_#{@polyglot_routes_locale}"
      return if as == ActionDispatch::Routing::Mapper::DEFAULT && has_named_route?(localized)

      @polyglot_routes_last_name = name
      localized
    end

    # Defines `products_path` / `products_url` that call the helper for I18n.locale.
    def define_polyglot_routes_helpers
      name = @polyglot_routes_last_name
      @polyglot_routes_last_name = nil
      return unless name

      { "path" => @set.named_routes.path_helpers_module,
        "url" => @set.named_routes.url_helpers_module }.each do |kind, helpers|
        helpers.define_method("#{name}_#{kind}") do |*args|
          PolyglotRoutes.call_helper(self, name, kind, args)
        end
      end
    end
  end
end

ActionDispatch::Routing::Mapper.prepend(PolyglotRoutes::Mapper)
