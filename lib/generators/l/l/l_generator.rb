#encoding: utf-8
module L
  module Generators
    require 'bundler'
    require 'rails/generators/active_record'
    require 'l/generators/actions'

    # Generator podstawowy odpowiedzialny za stworzenie całego szkieletu
    # aplikacji Lazy Programmera.
    #
    # Tworzone są modele User, Role i Ability. Generowane są potrzebne
    # migracje, dodawane nowe routing-i kopiowane pliki tłumaczeń i pliki
    # widoków (layouty, partiale, widoki devise).
    #
    # * <b>Lista dołączanych gemów</b>:
    #
    #   - +devise+
    #   - +cancan+
    #   - +globalize3+
    #   - +rails-i18n+
    #   - +paperclip+
    #   - +will_paginate+
    #   - +jquery-ui-rails+
    #   - +jquery-fileupload-rails+
    #   - +acts_as_tree+
    #   - +mysql2+
    #   - +tiny_mce_uploads+
    #
    # * *Parametry*:
    #
    #   - +--orm+ - nazwa klasy ORM, domyslnie: +active_record+
    #   - +--lang+, +-l+ - lista języków dostępnych w aplikacji. Jeśli na
    #     liście znajduje się więcej niż jeden język, domyślny jezykiem staje
    #     się język pierwszy na liscie i dodatkowo grenerowana jest akcja i
    #     routing do zminy języka i +before_filter+ do ustawiania języka z
    #     parametru +locale+ w url
    #   - +--bundle+ - Uruchom bundlera po dodaniu wszystkich potrzebnych gemów
    #     do aplikacjii, domślnie włączone. Jeśli wiesz że wszystkie gemy są zainstalowane użyj
    #     opcji +--skip-bundle+
    #   - +--views+ - Kopiuje widoki lazy programmera (layouty, paritale,
    #     widoki admina i usera), domyślnie włączone. Jeśli nie chcesz kopiować
    #     widoków (używane będą widoki z gema) użyj +--skip-views+
    #
    #
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

      class_option :gems, type: :boolean, default: true,
        desc:  "Dodaj wymagane gemy do pliku Gemfile (użyj --skip-gems " <<
               "jesli nie chcesz aby plik Gemfile był modyfikowany)"

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

      def self.source_root # :nodoc:
        @source_root ||= File.join(File.dirname(__FILE__), 'templates')
      end

      class << self
        delegate :next_migration_number, to: ActiveRecord::Generators::Base
      end

      ###### modyfikacja config/application.rb
      def add_application_config # :nodoc:
        requiry = <<-CONTENT
require 'mime/types'
require 'base64'
require 'will_paginate/array'
        CONTENT

        lang_symbols = options.lang.map{|l| l.to_sym }

        setting = <<-CONTENT
    config.time_zone = 'Warsaw'
    config.i18n.enforce_available_locales = false
    config.i18n.default_locale = #{lang_symbols.first.inspect}
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}').to_s]
    config.i18n.available_locales = #{lang_symbols.inspect}
        CONTENT

        inject_into_file "config/application.rb", requiry,
          after:  "require 'rails/all'\n", verbose: false
        inject_into_class "config/application.rb", 'Application', setting, verbose: false
        log :application, "Insert application configuration"
      end

      def add_gems # :nodoc:
        if options.gems
          gem 'devise', '~> 2.0'
          gem 'cancan'
          gem 'paperclip'
          gem 'jquery-ui-rails'
          gem 'jquery-fileupload-rails'
          gem 'remotipart'
          gem 'foundation-rails', '~> 5.2.0'
          gem 'font-awesome-rails', '~> 4.1.0'
          gem 'paranoia'

          gem 'globalize3', '~> 0.3.0'
          gem 'rails-i18n'

          gem 'will_paginate', '~> 3.0.0'
          gem 'acts_as_tree', '~> 0.1.1'
          gem 'mysql2'

          gem 'tinymce-rails', github: '1000ideas/tinymce-rails', branch: 'rails_3_2'

          gem_group :development do
            gem 'better_errors'
            gem 'binding_of_caller'
            gem 'quiet_assets'
          end
        else
          log :skip, <<-CONTENT
Adding gems

############### GEMS LIST ###############
gem 'devise', '~> 2.0'
gem 'cancan'
gem 'paperclip'
gem 'jquery-ui-rails'
gem 'jquery-fileupload-rails'
gem 'remotipart'
gem 'foundation-rails', '~> 5.2.0'
gem 'font-awesome-rails', '~> 4.1.0'
gem 'paranoia'

gem 'globalize3', '~> 0.3.0'
gem 'rails-i18n'

gem 'will_paginate', '~> 3.0.0'
gem 'acts_as_tree', '~> 0.1.1'
gem 'mysql2'

gem 'tinymce-rails', github: '1000ideas/tinymce-rails', branch: 'rails_3_2'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'quiet_assets'
end
          CONTENT
        end

        Bundler.with_clean_env do
          run 'bundle install'
        end if options.bundle and options.gems
      end

      def copy_initializer
        copy_file 'initializer_template.rb', 'config/initializers/lazy.rb'
      end

      def install_devise # :nodoc:
        generate 'devise:install -q'

        inject_into_file 'config/initializers/devise.rb',
          "\n  config.password_length = 5..128",
          after: /config\.password_length.*$/

        inject_into_file 'config/initializers/devise.rb',
          "\n  config.email_regexp = /\\A([^@\\s]+)@((?:[-a-z0-9]+\\.)+[a-z]{2,})\\Z/i",
          after: /config\.email_regexp.*$/
      end

      def tinymce_install # :nodoc:
        generate 'tinymce:install'
        rake "tinymce:lang:all"
        copy_file "assets/tinymce-rails-upload.css.scss", 'app/assets/javascripts/tinymce-rails-upload.css.scss'
      end

      def invoke_user_model # :nodoc:
        generate :model, "user --no-migration"
      end
      def create_migrations_files # :nodoc:
        migration_template 'users.rb', 'db/migrate/create_users.rb'
      end

      def inject_user_config_into_model # :nodoc:
        inject_into_class user_model_path, user_class_name, "include L::Concerns::LazyUser\n"
      end

      def generate_cancan_ability # :nodoc:
        generate 'cancan:ability'
      end

      def add_default_abilites # :nodoc:
        abilities = <<-CONTENT
    user ||= User.new

    if user.has_role? :admin
      can :manage, User
      can :manage, L::Page
      can :manage, L::News
      can :manage, L::Gallery
      can :manage, L::GalleryPhoto
      can :manage, L::NewsletterMail
    elsif user.has_role? :user
      can [:read, :update, :destroy], User, id: user.id
    end

    can :read, L::Page
    can :read, L::News
    can :read, L::Gallery
    can :read, L::GalleryPhoto
    can :create, L::NewsletterMail

        CONTENT
        insert_into_file 'app/models/ability.rb', abilities, after: "initialize(user)\n"

      end

      ##### dodanie danych do seeds.rb
      def add_seeds_data # :nodoc:
        dane = <<-CONTENT
print "Adding seeds data..."

passwd = if Rails.env.development?
  "admin"
else
 (0...5).map{ ('a'..'z').to_a[rand(26)] }.join
end

admin = User.create email: 'admin@admin.pl',
  password: passwd,
  password_confirmation: passwd,
  role: :admin

if admin.errors.empty?
  puts "\\nAdmin password: '\#{passwd}'"
else
  puts "\\nError while creating admin account: \#{admin.errors.full_messages.join('. ')}."
end

puts "done!"
        CONTENT

        prepend_file "db/seeds.rb", dane
      end

      ##### tworzenie routow do modulow: admin oraz users, one musza byc w kazdym cmsie
      def add_admin_and_users_routes # :nodoc:
        routes_content = load_template "routes.rb"
        inject_into_file "config/routes.rb",
          routes_content,
          after: %r{Application\.routes\.draw do$}
      end

      ##### przed instalacja naszego gema nie robimy rails g devise User,
      # wiec tutaj dodajemy do niego zmodyfikowany route'
      def add_devise_route # :nodoc:
        devise_route = <<-ROUTE

  devise_for :users,
    path: '',
    path_names: {
      :sign_in => 'login',
      :sign_out => 'logout',
      :sign_up => 'create',
      :password => 'reset_password',
      :confirmation => 'confirm_user',
      :registration => 'account'
    }
        ROUTE
        inject_into_file "config/routes.rb",
          devise_route,
          after: %r{Application\.routes\.draw do\n}
      end


      ##### dodanie treści do application controller
      def add_app_controller_content # :nodoc:
        remove_file "app/controllers/application_controller.rb"
        template 'application_controller.rb', "app/controllers/application_controller.rb"
      end


      ##### kopiowanie plikow tlumaczen
      def copy_locales # :nodoc:
        template "locales/pl.yml", "config/locales/pl.yml"
        copy_file "locales/devise.pl.yml", "config/locales/devise.pl.yml"
      end

      def copy_mailer_configuration # :nodoc:
        @mailer_perform_deliveries = false
        dev_content = load_template 'setup_mail.rb'
        application dev_content, :env => 'development'

        @mailer_perform_deliveries = true
        prod_content = load_template 'setup_mail.rb'
        application prod_content, :env => 'production'
      end

      def copy_application_views # :nodoc:
        directory "views/application", "app/views/application"
      end

      def copy_devise_views # :nodoc:
        directory "views/devise", "app/views/devise"
      end

      def copy_view # :nodoc:
        generate 'l:views' if options.views
      end

      def generate_mobile # :nodoc:
        generate 'l:mobile' if options.mobile
      end

      def remove_index_html # :nodoc:
        remove_file 'public/index.html'
      end

      protected

      def role_model_exists? # :nodoc:
        File.exists?(File.join(destination_root, role_model_path))
      end

      def role_model_path # :nodoc:
        @role_model_path ||= File.join("app", "models", "role.rb")
      end

      def role_class_name # :nodoc:
        @role_class_name ||= 'Role'
      end

      def user_model_exists? # :nodoc:
        File.exists?(File.join(destination_root, user_model_path))
      end

      def user_model_path # :nodoc:
        @user_model_path ||= File.join("app", "models", "user.rb")
      end

      def user_class_name # :nodoc:
        @user_class_name ||= 'User'
      end


    end
  end
end


