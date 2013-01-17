# encoding: utf-8
module L
  module Generators
    require 'rails/generators/active_record'
    require 'l/generators/actions'

    # Generator tworzący moduł aktualności.
    #
    # Tworzona jest migracja dla modelu News. Kopiowane są widoki modułu
    # aktualności. Dodawany jest routing. Dodawane jest szukanie newsów w akcji
    # wyszukiwarki. Dodawany jest link w panelu administracyjnym.
    #
    class NewsGenerator < ::Rails::Generators::Base
      include L::Generators::Actions
      include ::Rails::Generators::Migration

      desc "Tworzy modul newsow (tworzy migracje i kopiuje widoki)" <<
        "oraz dodaje routing."

      def self.source_root # :nodoc:
        @source_root ||= File.join(File.dirname(__FILE__), 'templates')
      end

      class << self
        delegate :next_migration_number, to: ActiveRecord::Generators::Base
      end

      def create_migration_file # :nodoc:
        migration_template 'news.rb', 'db/migrate/create_news.rb'
      end

      def copy_news_views # :nodoc:
        directory "../../../../../app/views/l/news", 
          "app/views/l/news"
      end

      def add_news_route # :nodoc:
        routing_code = <<-CONTENT
  resources :news, :controller => 'l/news' do
    collection do
      get :list
    end
  end
        CONTENT

        inject_into_file 'config/routes.rb', 
          routing_code, 
          :before => %r{^\s*resources :users}, 
          :verbose => false
        log :route, "resources :news"
      end

      def add_search_results_in_search_action # :nodoc:
        inject_into_file 'app/controllers/application_controller.rb',
          "    @news = L::News.search(params[:q])\n", :after => "def search\n"
      end

      def add_link_in_menu # :nodoc:
        link = <<-LINK
  <%= admin_menu_link(:news, news_index_path) if current_user.has_role? :admin %>
        LINK
        inject_into_file 'app/views/l/admins/partials/_header.erb', 
          link, 
          :before => "</div>\n<div id=\"submenu\">"
      rescue
        log :skip, "Adding link to admin menu"
      end

    end
  end
end
