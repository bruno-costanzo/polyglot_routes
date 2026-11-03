# frozen_string_literal: true

require "rails"
require "action_controller/railtie"
require "polyglot_routes"
require "minitest/autorun"

class TestApp < Rails::Application
  config.root = __dir__
  config.eager_load = false
  config.secret_key_base = "x" * 64
  config.hosts.clear
  config.logger = Logger.new(nil)
  config.i18n.available_locales = %i[en es]
  config.i18n.default_locale = :en
end

TestApp.initialize!

I18n.backend.store_translations(:es, routes: {
  products: "productos", new: "nuevo", edit: "editar", reviews: "opiniones", about: "sobre-nosotros"
})

TestApp.routes.draw do
  localized do
    root "pages#home"
    get "about", to: "pages#about"
    resources :products do
      resources :reviews, only: :index
    end
    get "contact", to: "pages#contact" # no translation for "contact"
  end

  localized(locales: %w[es]) do
    get "offers", to: "pages#offers"
  end

  localized do
    get "status", to: "api#status"
  end

  get "health", to: "pages#health"
end

class PagesController < ActionController::Base
  def show_locale = render(plain: "#{action_name}:#{I18n.locale}")
  alias home show_locale
  alias about show_locale
  alias contact show_locale
  alias health show_locale
  alias offers show_locale
end

class ApiController < ActionController::API
  def status = render(plain: "status:#{I18n.locale}")
end

class ProductsController < ActionController::Base
  def index = render(plain: "index:#{I18n.locale}:#{products_path}")
  def show = render(plain: "show:#{I18n.locale}:#{product_path(params[:id])}:#{switch_locale_path(:en)}")
  def new = render(plain: "new:#{I18n.locale}")
  def edit = render(plain: "edit:#{I18n.locale}")
end

class ReviewsController < ActionController::Base
  def index = render(plain: "reviews:#{I18n.locale}:#{product_reviews_path(params[:product_id])}")
end
