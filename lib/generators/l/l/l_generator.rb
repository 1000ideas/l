#encoding: utf-8
module L
  module Generators
    require 'bundler'
    require 'rails/generators/active_record'
    require 'l/generators/actions'

    class LGenerator < ::Rails::Generators::Base
      include ::Rails::Generators::Migration
      include L::Generators::Actions
      namespace 'l'   
 
      
      class_option :orm, :default => "active_record"

      class_option :lang, 
        aliases: '-l', 
        type: :array, 
        default: ['pl'], 
        desc: "Lista języków obsługiwanych przez aplikację." <<
          "Jeśli podany zostanie jeden (domyslnie pl) to zostaną" <<
          "wyłaczone funkcje przełącznia języków."

      class_option :bundle, type: :boolean, default: true, 
        desc:  "Uruchom bundlera po dodaniu gemów (użyj --skip-bundle " <<
               "jesli wiesz że wszystkie użyte gemy są zainstalowane)"

      class_option :views, type: :boolean, default: true, 
        desc:  "Kopiuj widoki lazy_programmera (użyj --skip-views " <<
               "jesli wiesz co robisz)"

      class_option :mobile,
        aliases: '-m',
        type: :boolean,
        default: false,
        desc:  "Generuj controler mobilny, przygotuj widoki i routes-y"


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
        gem 'devise', "~> 2.0.0"
        
        gem 'cancan'
        gem 'rolify'

        gem 'globalize3', :git => 'git://github.com/svenfuchs/globalize3.git'
        
        gem 'paperclip'

        gem 'will_paginate', '~> 3.0.0'
        gem 'acts_as_tree', '~> 0.1.1'
        gem 'mysql2'

        gem 'tiny_mce_uploads'

        Bundler.with_clean_env do
          run 'bundle install'
        end if options.bundle
      end

      def install_devise
        generate 'devise:install -q'
      end

      def tinymce_uploads_install
        generate 'tiny_mce_uploads'
      end
      
      def invoke_user_model
        generate :model, "user --no-migration"
      end
      def create_migrations_files
        migration_template 'users.rb', 'db/migrate/create_users.rb'
      end

      def inject_user_config_into_model
        user_class_setup = load_template('user_model.rb')
        inject_into_class user_model_path, user_class_name, user_class_setup
      end

      ##### Tworzenie CanCan::Ability
      def generate_cancan_ability
        generate 'cancan:ability'
      end

      def generate_rolify_role
        generate 'rolify:role -q'
      end

      def add_default_abilites
        abilities = <<-CONTENT
  user ||= User.new
  if user.has_role? :admin
    can :manage, :all
    can :manage, :self    
    can :read, :all
  elsif user.has_role? :user
    can :manage, :self    
    can :read, :all
  else
    can :read, :all
  end

        CONTENT
        insert_into_file 'app/models/ability.rb', abilities, after: "initialize(user)\n"

      end
      
      ##### dodanie danych do seeds.rb
      def add_seeds_data
        dane = <<-CONTENT
admin = User.create email:  "admin@admin.pl", password:  "admin", :password_confirmation => "admin"
admin.add_role :admin

print "Seeds added\n"
        CONTENT

        prepend_file "db/seeds.rb", dane
      end

      ##### tworzenie routow do modulow: admin oraz users, one musza byc w kazdym cmsie
      def add_admin_and_users_routes
        routes_content = load_template "routes.rb"
        inject_into_file "config/routes.rb", routes_content, after: "Application.routes.draw do\n"
      end

      ##### przed instalacja naszego gema nie robimy rails g devise User,
      # wiec tutaj dodajemy do niego zmodyfikowany rout
      def add_devise_route
        route 'devise_for :users, :path_prefix => "devise"'
      end
      
      ###### modyfikacja config/application.rb
      def add_application_config
        requiry = <<-CONTENT
require 'mime/types'
require 'base64'
require 'will_paginate/array'
        CONTENT
        
       lang_symbols = options.lang.map{|l| l.to_sym }

       setting = <<-CONTENT
    config.time_zone = 'Warsaw'
    config.i18n.default_locale = #{lang_symbols.first.inspect}
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}').to_s]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', 'admin', '*.{rb,yml}').to_s]
    config.i18n.available_locales = #{lang_symbols.inspect}
        CONTENT
        
        inject_into_file "config/application.rb", requiry, 
          after:  "require 'rails/all'\n", verbose: false
        inject_into_class "config/application.rb", 'Application', setting, verbose: false
        log :application, "Insert application configuration"
      end

      ##### dodanie treści do application controller
      def add_app_controller_content
        remove_file "app/controllers/application_controller.rb"
        template 'application_controller.rb', "app/controllers/application_controller.rb"
      end
      
      def add_app_helper_content
        helper_content = load_template 'application_helper.rb'
        inject_into_file "app/helpers/application_helper.rb", helper_content, after:  "module ApplicationHelper\n"
      end
      
      ##### kopiowanie plikow tlumaczen
      def copy_locales
        template "locales/pl.yml", "config/locales/pl.yml"
        copy_file "locales/devise.pl.yml", "config/locales/devise.pl.yml"
        copy_file "locales/admin/pl.yml", "config/locales/admin/pl.yml"
      end

      def copy_mailer_configuration
        @mailer_perform_deliveries = false
        dev_content = load_template 'setup_mail.rb'
        application dev_content, :env => 'development'

        @mailer_perform_deliveries = true
        prod_content = load_template 'setup_mail.rb'
        application prod_content, :env => 'production'
      end

      def add_assets_to_pipeline
        inject_into_file 'app/assets/javascripts/application.js', 
          "//= require lightbox\n",
          after: "jquery_ujs\n"

        inject_into_file 'app/assets/stylesheets/application.css', 
          "\n *= require lightbox\n *= require lazy", 
          before: "\n*/"
      end


      def copy_application_views
        directory "views/application", "app/views/application"
      end

      def copy_devise_views
        directory "views/devise", "app/views/devise"
      end

      def copy_shared_views
        directory "views/shared", "app/views/shared"
      end

      def copy_view
        generate 'l:views' if options.views
      end

      def add_flash_sessions_cookie_middleware
        _config = <<-CONTENT
Rails.application.config.middleware.insert_before(
  Rails.application.config.session_store,
  FlashSessionCookieMiddleware,
  Rails.application.config.session_options[:key]
)
        CONTENT
        append_to_file 'config/initializers/session_store.rb', _config, verbose: false
        log :initializers, 'Add FlashSessionCookieMiddleware to session_store.rb'
      end

      def generate_mobile
        generate 'l:mobile' if options.mobile
      end

      def remove_index_html
        remove_file 'public/index.html'
      end

      protected

      def role_model_exists?
        File.exists?(File.join(destination_root, role_model_path))
      end

      def role_model_path
        @role_model_path ||= File.join("app", "models", "role.rb")
      end

      def role_class_name
        @role_class_name ||= 'Role'
      end

      def user_model_exists?
        File.exists?(File.join(destination_root, user_model_path))
      end

      def user_model_path
        @user_model_path ||= File.join("app", "models", "user.rb")
      end

      def user_class_name
        @user_class_name ||= 'User'
      end


    end
  end
end


