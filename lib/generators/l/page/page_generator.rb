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
          get :edit_draft
          put :update_draft
          get :hide, defaults: { status: 1 }
          get :unhide, action: 'hide', defaults: { status: 0 }
        end
        collection do
          put :sort
          constraints(lambda {|req| req.params.has_key?(:ids)}) do
            delete :bulk_destroy, action: :selection, defaults: {bulk_action: :destroy}
            put :bulk_hide, action: :selection, defaults: {bulk_action: :hide}
            put :bulk_unhide, action: :selection, defaults: {bulk_action: :unhide}
          end
        end
      end

        CONTENT
        inject_into_file 'config/routes.rb',
          routing_code,
          after: %r{^\s*scope module: 'l/admin'.*\n},
          verbose: false
        log :route, "resources :pages"

        routing_code = <<-CONTENT 
        match 'draft/:id' => 'l/pages#show_draft', as: :page_draft
        match '*token' => 'l/pages#show', as: :page_token
        CONTENT
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
      def add_cancan_abilities # :nodoc:
        cancan_manage_code = <<-CONTENT
        can :manage, L::Page::Draft
        CONTENT
        cancan_read_code = <<-CONTENT
        can :read, L::Page::Draft
        CONTENT

        inject_into_file 'app/models/ability.rb',
          cancan_manage_code,
          after: %r{^\s*can :manage, L::Page.*\n},
          verbose: false
        inject_into_file 'app/models/ability.rb',
          cancan_read_code,
          after: %r{^\s*can :read, L::Page.*\n},
          verbose: false
        
      end
    end
  end
end
