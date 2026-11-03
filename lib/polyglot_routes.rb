# frozen_string_literal: true

require "i18n"
require "action_dispatch"
require "polyglot_routes/version"
require "polyglot_routes/mapper"
require "polyglot_routes/controller"
require "polyglot_routes/railtie" if defined?(Rails::Railtie)

module PolyglotRoutes
  DYNAMIC_SEGMENT = /[:*()]/

  module_function

  def locales
    I18n.available_locales.map(&:to_s)
  end

  def default_locale
    I18n.default_locale.to_s
  end

  # "/products/:id/edit" + "es" => "/es/productos/:id/editar"
  def translate_path(path, locale)
    segments = path.split("/").map do |segment|
      next segment if segment.empty? || segment.match?(DYNAMIC_SEGMENT)

      I18n.t(segment, scope: :routes, locale: locale, default: segment)
    end

    translated = segments.join("/")
    translated = "/#{translated}" unless translated.start_with?("/")
    return translated if locale == default_locale

    translated == "/" ? "/#{locale}" : "/#{locale}#{translated}"
  end

  # Called by `products_path`: picks `products_es_path` for the current locale.
  def call_helper(context, name, kind, args)
    args = args.dup
    options = args.last.is_a?(Hash) ? args.pop.dup : {}
    wanted = options.key?(:locale) ? options.delete(:locale) : I18n.locale
    args << options unless options.empty?

    locale = [wanted.to_s, default_locale, *locales].find do |candidate|
      context.respond_to?("#{name}_#{candidate}_#{kind}")
    end
    context.public_send("#{name}_#{locale}_#{kind}", *args)
  end
end
