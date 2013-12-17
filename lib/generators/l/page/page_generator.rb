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
    class PageGenerator < ::Rails::Generators::Base
      include L::Generators::Actions
      include ::Rails::Generators::Migration

      desc "Tworzy modul stron (tworzy migracje i kopiuje widoki)" <<
           "oraz dodaje routing."

      def self.source_root # :nodoc:
        @source_root ||= File.join(File.dirname(__FILE__), 'templates')
      end

      class << self
        delegate :next_migration_number, to: ActiveRecord::Generators::Base
      end

      def create_migration_file # :nodoc:
        migration_template 'pages.rb', 'db/migrate/create_pages.rb'
      end

      def copy_pages_views # :nodoc:
        directory "../../../../../app/views/l/pages", 
          "app/views/l/pages"

        directory "../../../../../app/views/l/admin/pages", 
          "app/views/l/admin/pages"
      end

      def add_pages_route # :nodoc:
        routing_code = <<-CONTENT

      resources :pages, except: [:show] do
        member do
          get :hide, defaults: { status: 1 }
          get :unhide, action: 'hide', defaults: { status: 0 }
          match 'after/:target_id', action: :after, via: :post, as: :after
        end
        post :selection, on: :collection
      end

        CONTENT
        inject_into_file 'config/routes.rb', 
          routing_code, 
          after: %r{^\s*scope module: 'l/admin'.*\n}, 
          verbose: false
        log :route, "resources :pages"

        routing_code = "match '*token' => 'l/pages#show', as: :page_token"
        inject_into_file 'config/routes.rb',
          "  #{routing_code}\n" ,
          before: %r{^\s*root to:}, 
          verbose: false
        log :route, routing_code
      end

      def add_search_results_in_search_action # :nodoc:
        inject_into_file 'app/controllers/application_controller.rb',
          "    @pages = L::Page.search(params[:q])\n",
          after: "def search\n"
      end

      def add_link_in_menu # :nodoc:
        link = <<-LINK
  <%= admin_menu_link(:pages) if current_user.has_role? :admin %>
        LINK
        inject_into_file 'app/views/l/admins/partials/_header.erb',
          link,
          before: "</div>\n<div id=\"submenu\">"
      rescue Exception => ex
        log :skip, "Adding link to admin menu"
      end

    end
  end
end
