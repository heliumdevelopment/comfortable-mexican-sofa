# ComfortableMexicanSofa
[![Gem Version](https://img.shields.io/gem/v/comfortable_mexican_sofa.svg?style=flat)](http://rubygems.org/gems/comfortable_mexican_sofa) [![Gem Downloads](https://img.shields.io/gem/dt/comfortable_mexican_sofa.svg?style=flat)](http://rubygems.org/gems/comfortable_mexican_sofa) [![Build Status](https://img.shields.io/travis/comfy/comfortable-mexican-sofa.svg?style=flat)](https://travis-ci.org/comfy/comfortable-mexican-sofa) [![Dependency Status](https://img.shields.io/gemnasium/comfy/comfortable-mexican-sofa.svg?style=flat)](https://gemnasium.com/comfy/comfortable-mexican-sofa) [![Code Climate](https://img.shields.io/codeclimate/github/comfy/comfortable-mexican-sofa.svg?style=flat)](https://codeclimate.com/github/comfy/comfortable-mexican-sofa) [![Coverage Status](https://img.shields.io/coveralls/comfy/comfortable-mexican-sofa.svg?style=flat)](https://coveralls.io/r/comfy/comfortable-mexican-sofa?branch=master)

ComfortableMexicanSofa is a powerful Rails 4 CMS Engine

## Features

* Simple integration with Rails 4 apps
* Build your application in Rails, not in CMS
* Powerful page templating capability using [Tags](https://github.com/comfy/comfortable-mexican-sofa/wiki/Tags)
* [Multiple Sites](https://github.com/comfy/comfortable-mexican-sofa/wiki/Sites) from a single installation
* Multi-Language Support (i18n) (cs, da, de, en, es, fr, it, ja, nb, nl, pl, pt-BR, ru, sv, uk, zh-CN, zh-TW)
* [Fixtures](https://github.com/comfy/comfortable-mexican-sofa/wiki/Working-with-CMS-fixtures) for initial content population
* [Revision History](https://github.com/comfy/comfortable-mexican-sofa/wiki/Revisions)
* [Great extendable admin interface](https://github.com/comfy/comfortable-mexican-sofa/wiki/Reusing-sofa%27s-admin-area) built with [Bootstrap](http://twitter.github.com/bootstrap/), [CodeMirror](http://codemirror.net/) and [Redactor](http://imperavi.com/redactor)

## Installation

Add gem definition to your Gemfile:

```ruby
gem 'comfortable_mexican_sofa', '~> 1.12.0'
```

Then from the Rails project's root run:

    bundle install
    rails generate comfy:cms
    rake db:migrate

Now take a look inside your `config/routes.rb` file. You'll see where routes attach for the admin area and content serving. Make sure that content serving route appears as a very last item.

```ruby
comfy_route :cms_admin, :path => '/admin'
comfy_route :cms, :path => '/', :sitemap => false
```

If you get an `Invalid route name` error, look inside your route file to see if there's already the CMS route being duplicated.

Add to `application_controller.rb`
```
alias_method :current_user, :current_comfy_user

layout :layout_by_resource

protected

def layout_by_resource
  if devise_controller?
    "comfy/backend"
  else
    "application"
  end
end
```

## Adding settings

Within the `comfortable_mexican_sofa.rb`, add:
```
config.settings = %w( site_title )
```

## Adding templates

If you want to add custom templates, add an item to the routes file for that template like:
```
controller :templates do
  get 'about', :action => 'about'
end
```

Then add `app/views/templates/about.slim`
