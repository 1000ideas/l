# L

L is a CMS-like gem for very lazy programmers. It gives you a bunch of generators and helpers for quick and easy creation of a fully working CMS with users, news, static pages, galleries and newsletter modules.

## Getting started

L in version 0.7.x works with Rails 3.2. Newer versions of Rails will not work. You can add it to your Gemfile with:

```ruby
gem 'l', github: '1000ideas/l', tag: 'v1.0.14'
```

Run the bundle command to install it.

After you add L to your Gemfile and bundle it, you need to run the generator:

```console
rails generate l
```

Or if you are very lazy even more simply:

```console
rails g l
```
Make sure that the gems in your Gemfile do not duplicate.
Next you have to run database migrations:

```console
rake db:migrate
```

To create admin user, run:

```console
rake db:seed
```

And now just start your rails server! It works!

If you want to add a module, run one of these commands:

```console
rails g l:news # News module
rails g l:page # Static pages module
rails g l:galleries # Galeries module
rails g l:newsletter # Newsletter module
```

If you want to add your own module to operate on some model run:

```console
rails g l:module MODULE_NAME field:type field:type ...
```

It works just like a `model` generator with some extensions. You can use `file` type if you want the field to be a paperclip attachment. Also typing `tinymce_[theme]` is allowed for text field with TinyMCE editor, where `[theme]` is one of the defined TinyMCE themes: `simple` and `advance`.

## Contributing to L

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone hasn't already requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or it is otherwise necessary, that is fine, but please isolate it to its own commit so I can cherry-pick around it.

## Creating custom module with draft
Pages, news, galleries and newsletter have drafts by default but you can add drafts also in new custom modules.
You just need to run 
```console
rails g l:module MODULE_NAME field:type field:type ... --has_draft
```
then add this line to your create_#{model}.rb migration file and run migrations
```console
t.integer :author_id
```
insert at the top of model
```console
has_draft 
	attr_accessible :module_name_id, :field, :field ...
end

attr_accessible :draft, :field, :field ... 
```

## Copyright

Copyright (c) 2012 1000ideas.
See LICENSE.txt for further details.

## Developers

Bartek Bułat
Ewelina Mijal
Krzysztof Kosman
