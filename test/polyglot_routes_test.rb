# frozen_string_literal: true

require "test_helper"

class RecognitionTest < ActionDispatch::IntegrationTest
  def app = TestApp

  def assert_page(path, body)
    get path
    assert_response :success
    assert_equal body, response.body
  end

  test "default locale has no prefix" do
    assert_page "/products", "index:en:/products"
    assert_page "/products/new", "new:en"
    assert_page "/products/7/edit", "edit:en"
    assert_page "/", "home:en"
  end

  test "other locales get a prefix and translated segments" do
    assert_page "/es/productos", "index:es:/es/productos"
    assert_page "/es/productos/nuevo", "new:es"
    assert_page "/es/productos/7/editar", "edit:es"
    assert_page "/es/sobre-nosotros", "about:es"
    assert_page "/es", "home:es"
  end

  test "nested resources are translated" do
    assert_page "/es/productos/7/opiniones", "reviews:es:/es/productos/7/opiniones"
  end

  test "missing translation keeps the original segment" do
    assert_page "/es/contact", "contact:es"
  end

  test "routes outside localized are not changed" do
    assert_page "/health", "health:en"
    get "/es/health"
    assert_response :not_found
  end

  test "untranslated paths do not exist in other locales" do
    get "/es/products"
    assert_response :not_found
  end

  test "localized can use only some locales" do
    assert_page "/es/offers", "offers:es"
    get "/offers"
    assert_response :not_found
  end

  test "API controllers also get the locale" do
    assert_page "/es/status", "status:es"
  end

  test "switch_locale_path gives the current page in another locale" do
    get "/es/productos/7?tab=info"
    assert_equal "show:es:/es/productos/7:/products/7?tab=info", response.body
  end
end

class HelpersTest < ActiveSupport::TestCase
  include TestApp.routes.url_helpers

  def default_url_options = { host: "example.com" }

  test "helpers follow I18n.locale" do
    assert_equal "/products", products_path
    I18n.with_locale(:es) do
      assert_equal "/es/productos", products_path
      assert_equal "/es/productos/3/editar", edit_product_path(3)
      assert_equal "http://example.com/es/productos/nuevo", new_product_url
      assert_equal "/es", root_path
    end
  end

  test "locale option picks a locale" do
    assert_equal "/es/productos/3", product_path(3, locale: :es)
    assert_equal "/products/3?page=2", product_path(3, locale: :en, page: 2)
  end

  test "unknown locale falls back to the default locale" do
    assert_equal "/products", products_path(locale: :fr)
  end

  test "a helper without the wanted locale uses the first locale it has" do
    assert_equal "/es/offers", offers_path
  end

  test "per-locale helpers exist" do
    assert_equal "/es/productos", products_es_path
    assert_equal "/products", products_en_path
  end
end

class LocalizedTest < ActiveSupport::TestCase
  test "localized rejects locales outside I18n.available_locales" do
    error = assert_raises(ArgumentError) do
      ActionDispatch::Routing::RouteSet.new.draw do
        localized(locales: %i[es fr]) { get "legacy", to: "pages#legacy" }
      end
    end
    assert_equal "Unknown locales for localized: fr", error.message
  end
end

class LoadTest < ActiveSupport::TestCase
  test "the gem loads without Rails" do
    lib = File.expand_path("../lib", __dir__)
    script = 'require "polyglot_routes"; exit(defined?(PolyglotRoutes::Railtie) ? 1 : 0)'
    assert system(RbConfig.ruby, "-I", lib, "-e", script), "Railtie must load only with Rails"
  end
end
