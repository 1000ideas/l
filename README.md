# L

L is CMS-like gem for very lazy programmers. It gives you bunch of generators and helpers for quick and easy creating fully working CMS with users, news, static pages, galleries and newsletter modules.

## Getting started

L in version 0.7.x working with Rails 3.2. You can add it to your Gemfile with:

```ruby
gem 'l', github: '1000ideas/l'
```

Run the bundle command to install it.

After you install L and add it to your Gemfile, you need to run the generator:

```console
rails generate l
```

Or even simplier if you are very lazy:

```console
rails g l
```

Next you have to run database migrations:

```console
rake db:migrate
```

For creating admin user, run:

```console
rake db:seed
```

And now just start your rails server! It works!

If you want to add some module, run one of this commands:

```console
rails g l:news # News module
rails g l:page # Static pages module
rails g l:gallery # Galeries module
rails g l:newsletter # Newsletter module
```

If you want to add your own module to operate on some model run:

```console
rails g l:module MODULE_NAME field:type field:type ...
```

Its working just like `model` generator with some extension. You can use `file` type if you want field be a paperclip attachment. Also type `tiny_mce_[theme]` is allowed for text field with TinyMCE editor, where `[theme]` is one of defined TinyMCE themes: `fileupload`, `advance` and `simple`.



## Contributing to L
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 1000ideas. 
See LICENSE.txt for further details.

## Developers

Bartek Bułat
Ewelina Mijal
Krzysztof Kosman
