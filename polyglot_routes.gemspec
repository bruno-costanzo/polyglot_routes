# frozen_string_literal: true

require_relative "lib/polyglot_routes/version"

Gem::Specification.new do |spec|
  spec.name = "polyglot_routes"
  spec.version = PolyglotRoutes::VERSION
  spec.authors = ["Bruno Costanzo"]
  spec.email = ["dev.bcostanzo@gmail.com"]
  spec.summary = "Translated Rails routes for every locale, with no setup."
  spec.description = "Wrap your routes in `localized` and get one translated route per locale, " \
                     "locale-aware URL helpers and I18n.locale set from the URL."
  spec.homepage = "https://github.com/bruno-costanzo/polyglot_routes"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir["lib/**/*.rb", "README.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]

  spec.add_dependency "actionpack", ">= 7.1"
  spec.add_dependency "railties", ">= 7.1"
end
