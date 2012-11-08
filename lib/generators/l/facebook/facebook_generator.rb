#encoding: utf-8

module L
  module Generators
    require 'bundler'
    require 'rails/generators/active_record'
    require 'l/generators/actions'

    class FacebookGenerator < ::Rails::Generators::Base
      include ::Rails::Generators::Migration
      include L::Generators::Actions

      desc "Generator odpowiedzialny za stworzenie modeli User i Role," <<
        "potrzebnych migracji, dodanie routingow, skopiowanie plikow tlumaczen," <<
        "folderow layouts, partials, widokow devise, admins, users" <<
        "oraz calego folderu public."

      def self.source_root
        @source_root ||= File.join(File.dirname(__FILE__), 'templates')
      end
      
      class << self
        delegate :next_migration_number, :to => ActiveRecord::Generators::Base
      end

      def add_gems
        gem 'koala'
        gem 'omniauth-facebook'

        Bundler.with_clean_env do
          run 'bundle install'
        end
      end

      def add_user_migration
        migration_template 'users_migration.rb', 'db/migrate/add_facebook_to_user.rb'
      end

      def modify_user_class
        inject_into_class "app/models/user.rb", User do
          "  has_many :authentications\n"
        end
        inject_into_class "app/models/user.rb", User do
          load_template("user_methods.rb")
        end
        inject_into_file "app/models/user.rb", after: %r{\n\s+devise } do
          ":omniauthable, "
        end
        inject_into_file "app/models/user.rb", after: %r{\n\s+attr_accessible } do
          ":fbid, :first_name, :last_name, "
        end
      end

      def add_authentication
        generate :model, "authentication user_id:integer token:string uid:string"
        inject_into_class "app/models/authentication.rb", 'Authentication' do
          "  belongs_to :user\n"
        end if File.exists? "app/models/authentication.rb"
      end

      def omniauth_user_controller
        empty_directory 'app/controllers/users'
        template 'omniauth_callbacks_controller.rb', 
          'app/controllers/users/omniauth_callbacks_controller.rb'
      end

      def generate_facebook_controller
        template "facebook_controller.rb", "app/controllers/facebook_controller.rb"
        directory 'facebook', 'app/views/facebook'
      end


      def configuration
        initializer "00_facebook.rb" do
          load_template "initializer.rb"
        end

        copy_file 'ca-bundle.crt', 'config/ca-bundle.crt' 
        inject_into_file "config/initializers/devise.rb", after: %r{Devise\.setup.+\n} do
          load_template "devise.rb"
        end
      end

      def add_routes
        route %Q{namespace :facebook do
    match '/', action: :index, via: [:get, :post]
  end}
        inject_into_file 'config/routes.rb', after: 'devise_for :users' do
          ', :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" } '
        end
      end

    end
  end
end
