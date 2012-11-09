#encoding: utf-8

module L
  module Generators
    require 'bundler'
    require 'rails/generators/active_record'
    require 'l/generators/actions'

    class FacebookGenerator < ::Rails::Generators::Base
      include ::Rails::Generators::Migration
      include L::Generators::Actions

      desc "Generator odpowiedzialny za stworzenie struktury pozwalającej na logowanie się " <<
        "do aplikacji za pomocą konta facebook, oraz integracje z facebookowym canvasem"

      class_option :bundle, type: :boolean, default: true, 
        desc:  "Uruchom bundlera po dodaniu gemów (użyj --skip-bundle " <<
               "jesli wiesz że wszystkie użyte gemy są zainstalowane)"

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
        end if options.bundle
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

        initializer "01_google_analytics.rb" do
          "$google_analytics_id = ''"
        end

        copy_file 'ca-bundle.crt', 'config/ca-bundle.crt' 
        inject_into_file "config/initializers/devise.rb", after: %r{Devise\.setup.+\n} do
          load_template "devise.rb"
        end
      end

      def add_routes
        routes_content = load_template "routes.rb"
        inject_into_file "config/routes.rb", 
          routes_content, 
          after: "Application.routes.draw do\n", 
          verbose: false
        log :route, 'resource :facebook'
        inject_into_file 'config/routes.rb', after: 'devise_for :users' do
          ', :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" } '
        end
      end

      def add_assets
        create_file "app/assets/javascripts/facebook.js"
        create_file "app/assets/stylesheets/facebook.css"
        environment(nil, env: 'production') do 
          "# Precompule facebook assets\n" +
          "  config.assets.precompile += ['facebook.css', 'facebook.js']\n"
        end
      end

    end
  end
end
