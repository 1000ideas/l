# encoding: utf-8

module L
  module Generators
    require 'rails/generators/active_record'
    require 'l/generators/actions'

    # Generator tworzący moduł stron stałych.
    #
    # Tworzona jest migracja dla modelu Page. Kopiowane są widoki modułu,
    # dodawany jest routing. Dodawane jest szukanie stron w akcji wyszukiwarki.
    # Dodawany jest link w menu w panelu administracyjnym.
    #
    class SettingsGenerator < ::Rails::Generators::Base
      include L::Generators::Actions
      include ::Rails::Generators::Migration

      desc "Tworzy modul ustawień (tworzy migracje i kopiuje widoki)" <<
           "oraz dodaje routing."

      def self.source_root # :nodoc:
        @source_root ||= File.join(File.dirname(__FILE__), 'templates')
      end

      class << self
        delegate :next_migration_number, to: ActiveRecord::Generators::Base
      end

      def create_migration_file # :nodoc:
        migration_template 'create_contents.rb', 'db/migrate/create_contents.rb'
      end

      def add_pages_route # :nodoc:
        routing_code = <<-CONTENT
          scope controller: :admin do
            get :settings
            put :settings
          end
        CONTENT

        inject_into_file 'config/routes.rb',
          routing_code,
          after: %r{^\s*scope module: 'l/admin'.*\n},
          verbose: false
        log :route, "admin#settings routes"
      end

      def add_settings_initializer
        initializer "settings.rb" do
          <<-CONTENT
L::Settings.configure do |config|
  # Text fields
  # config.create_text_field :name, :name_2

  # Text field with defaut value
  # config.create_text_field name: 'default'

  # Boolean field
  # config.create_boolean_field :terms

  # Date/Time field
  # config.create_time_field :terms

  # Create your own field
  # config.fields << :name
  # config.define_method(:name) do
  # # getter contents...
  # end
  # config.define_method(:"\#{name}_for_save") do
  # # getter contents... (saved in database)
  # end
  # config.define_method(:"\#{name}=") do |value|
  # # setter contents...
  # end

  # Create your own methods
  # config.define_method(:name) do |args|
  # # contents...
  # end
end
          CONTENT
        end
      end

      def insert_helper_to_application_controller # :nodoc:
        code = <<-CONTENT
  def _settings
    L::Settings.instance
  end
  private :_settings
  helper_method :_settings
        CONTENT

        inject_into_file 'app/controllers/application_controller.rb', code, after: /class ApplicationController.*\n/
      end

    end
  end
end
