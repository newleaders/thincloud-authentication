# Thincloud::Authentication

[![Build Status](https://secure.travis-ci.org/newleaders/thincloud-authentication.png)](http://travis-ci.org/newleaders/thincloud-authentication) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/newleaders/thincloud-authentication)

## Description

A Rails Engine to provide authentication for Thincloud applications.

## Requirements

This gem requires Rails 3.2+ and has been tested on the following versions:

* 3.2

This gem has been tested against the following Ruby versions:

* MRI 1.9.2
* MRI 1.9.3
* JRuby 1.6+ (with `JRUBY_OPTS=--1.9`)
* Rubinius 2.0.0dev (with `RBXOPT=-X19`)

This gem has been tested against the following database versions:

* MySQL 5.0, 5.5
* PostgreSQL 9.1, 9.2
* SQLite 3


## Installation

Add this line to your application's Gemfile:

``` ruby
gem "thincloud-authentication"
```

* Run `bundle`
* Copy the migrations and prepare your databases:

```
$ rake thincloud_authentication:install:migrations db:migrate db:test:prepare
```

* Mount the engine in your `config/routes.rb` file:

```ruby
mount Thincloud::Authentication::Engine => "/auth", as: "auth_engine"
```

Using the example above, you may now login or signup at [http://lvh.me:3000/auth](http://lvh.me:3000/auth).

### Prerequisites

The following must be true for `thincloud-authentication` to operate properly:

* A `root_url` must be defined in `config/routes.rb`
* A `User` model must exist


## Configuration

The `Thincloud::Authentication` module accepts a `configure` block with options to customize the engine behavior.


### Layouts

Set the `layout` option to customize the layout used by all thincloud-authentication views:

```ruby
Thincloud::Authentication.configure do |config|
  config.layout = "other"
end
```

### Mailers

Set the `mailer_sender` option to customize the "From" address of the emails sent from the system:

```ruby
Thincloud::Authentication.configure do |config|
  config.mailer_sender = "app@example.com"
end
```

### Redirect Paths

Set the following options to customize the redirects that occur after certain actions:

```ruby
Thincloud::Authentication.configure do |config|
  config.after_login_path = "/dashboard"
  config.after_logout_path = "/"
  config.after_registration_path = "/""
  config.after_verification_path = "/dashboard"
end
```


### Additional provider strategies

* Require the `omniauth-#{provider}` gem before the `thincloud-authentication` gem in the `Gemfile`:

```ruby
gem "omniauth-linkedin"
gem "omniauth-stripe-connect"
gem "thincloud-authentication"
```

* Add a key to the `providers` hash with the name of the strategy, followed by additional options for `require`, `scopes` and `fields` as needed. Additionally, you will need to provide environment variables (prefixed with the provider name), with the `consumer_key` and `consumer_secret` values from your OAuth provider.

To enable the [LinkedIn](https://github.com/skorks/omniauth-linkedin) and [Stripe Connect](https://github.com/isaacsanders/omniauth-stripe-connect) providers:

* Provide values for following environment variables:
    * `ENV["LINKEDIN_CONSUMER_KEY"]`
    * `ENV["LINKEDIN_CONSUMER_SECRET"]`
    * `ENV["STRIPE_CONNECT_CONSUMER_KEY"]`
    * `ENV["STRIPE_CONNECT_CONSUMER_SECRET"]`
* Add the file `config/initializers/thincloud_authentication.rb` with the following contents:

```ruby
Thincloud::Authentication.configure do |config|
  config.providers = {
    linkedin: {
      scopes: "r_emailaddress r_basicprofile",
      fields: ["id", "email-address", "first-name", "last-name", "headline",
               "industry", "picture-url", "location", "public-profile-url"]
    },
    stripe_connect: {
      require: "omniauth-stripe-connect",
      scopes: "read_write"
    }
  }
end
```


### Vanity Routes

If you want to customize the routes (remove the `/auth` prefix), you may add the following to your `config/routes.rb` file:

```ruby
get "signup", to: "thincloud/authentication/registrations#new", as: "signup"
get "login", to: "thincloud/authentication/sessions#new", as: "login"
delete "logout", to: "thincloud/authentication/sessions#destroy", as: "logout"
```

Using the example above, you will have the following routes locally:

* `signup_url` points to "/signup"
* `login_url` points to "/login"
* `logout_url` points to "/logout" - Make sure to use the `delete` method to logout.


### Redirection

You can customize the paths used to redirect users after login, logout and registration by overriding the corresponding methods in your ApplicationController, or specific controllers, as needed.

* `after_login_path` is used after the user logs in.
* `after_logout_path` is used after the user logs out.
* `after_registration_path` is used after the user registers.


## TODO

* Add "forgot password" functionality
* Add multiple, configurable strategy options
* Add a configuration option to customize the mailers


## Contributing

1. [Fork it](https://github.com/newleaders/thincloud-authentication/fork_select)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. [Create a Pull Request](https://github.com/newleaders/thincloud-authentication/pull/new)


## License

* Freely distributable and licensed under the [MIT license](http://newleaders.mit-license.org/2012/license.html).
* Copyright (c) 2012 New Leaders ([opensource@newleaders.com](opensource@newleaders.com))
* [https://newleaders.com](https://newleaders.com)
