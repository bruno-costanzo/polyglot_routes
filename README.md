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

## Devise

Use Devise 4.9.4 or newer. Devise then keeps `I18n.locale` when authentication fails, so its
flash messages use the locale of the URL
([heartcombo/devise#5567](https://github.com/heartcombo/devise/pull/5567)).
Older versions show these messages in the default locale.

## Why not route_translator?

[route_translator](https://github.com/enriclluelles/route_translator) is the mature gem for
this job, and it uses the same `localized` block. polyglot_routes is a smaller option:

|                               | polyglot_routes              | route_translator                         |
|-------------------------------|------------------------------|------------------------------------------|
| Set `I18n.locale` from the URL | Automatic, in every controller | Add `around_action :set_locale_from_url` |
| Link to the current page in another locale | `switch_locale_path(:es)`, keeps the query string | `url_for(locale: "es")`, the locale must be a string |
| Configuration                 | None                         | `force_locale`, `hide_locale`, host-based locales, unlocalized routes and more |
| Size                          | About 200 lines              | Larger, with years of edge cases fixed   |

Use polyglot_routes when the default behaviour is all you need.
Use route_translator when you need one of its options.

## License

MIT
