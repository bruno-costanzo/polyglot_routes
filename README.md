# polyglot_routes

[![Gem Version](https://img.shields.io/gem/v/polyglot_routes)](https://rubygems.org/gems/polyglot_routes)
[![CI](https://github.com/bruno-costanzo/polyglot_routes/actions/workflows/ci.yml/badge.svg)](https://github.com/bruno-costanzo/polyglot_routes/actions/workflows/ci.yml)
[![Coverage](https://img.shields.io/badge/coverage-100%25-brightgreen)](test)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.2-CC342D)](polyglot_routes.gemspec)
[![Rails](https://img.shields.io/badge/rails-%3E%3D%207.1-D30001)](polyglot_routes.gemspec)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE.txt)

Translated Rails routes for every locale. No setup: you only write routes.

## Install

```ruby
gem "polyglot_routes"
```

## Use

```ruby
# config/routes.rb
Rails.application.routes.draw do
  localized do
    root "pages#home"
    resources :products
  end
end
```

```yaml
# config/locales/es.yml
es:
  routes:
    products: productos
    new: nuevo
    edit: editar
```

With `I18n.available_locales = [:en, :es]` and `:en` as the default locale:

| Path                       | Controller        | `I18n.locale` |
|----------------------------|-------------------|---------------|
| `/products/new`            | `products#new`    | `en`          |
| `/es/productos/nuevo`      | `products#new`    | `es`          |
| `/es`                      | `pages#home`      | `es`          |

- The default locale has no prefix. Other locales get `/<locale>`.
- A segment without a translation stays the same.
- Each request sets `I18n.locale` from the URL.

## Helpers

```ruby
products_path                 # follows I18n.locale
products_path(locale: :es)    # "/es/productos"
products_es_path              # one helper per locale
switch_locale_path(:en)       # current page in another locale (views and controllers)
```

Only some locales: `localized(locales: %i[en es]) { ... }`.

## License

MIT
