# Thincloud::Authentication

## Description

A Rails Engine to provide authentication for Thincloud applications.

## Requirements

This gem requires Rails 3.2+ and has been tested on the following versions:

* 3.2

This gem has been tested against the following Ruby versions:

* 1.9.3


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
