# encoding: utf-8
module L
  module Generators
    require 'rails/generators/active_record'
    require 'l/generators/actions'

    # Generator tworzący moduł galerii.
    #
    # Kopiowane są migracje dla modeli Gallery i GalleryPhoto, kopiowane są też
    # widoki modułu galerii. Dodawany jest routing. Dodawane jest szukanie w
    # akcji wyszukiwarki. Dodawany jest link w menu panelu administracyjnego.
    #
    class GalleriesGenerator < ::Rails::Generators::Base
      include L::Generators::Actions
      include ::Rails::Generators::Migration

      desc "Tworzy modul galerii (tworzy migracje i kopiuje widoki)" <<
        "oraz dodaje routing."

      def self.source_root # :nodoc:
        @source_root ||= File.join(File.dirname(__FILE__), 'templates')
      end

      class << self
        delegate :next_migration_number, to: ActiveRecord::Generators::Base
      end

      def create_migration_file # :nodoc:
        migration_template 'galleries.rb', 'db/migrate/create_galleries.rb'
        migration_template 'gallery_photos.rb', 'db/migrate/create_gallery_photos.rb'
      end

      def copy_galleries_views # :nodoc:
        directory "../../../../../app/views/l/galleries", 
          "app/views/l/galleries"
        directory "../../../../../app/views/l/gallery_photos", 
          "app/views/l/gallery_photos"
      end

      def add_galleries_route # :nodoc:
        routing_code = <<-CONTENT

    resources :galleries, :controller => 'l/galleries'   do
      collection do
        get :list
        post :upload
      end
      resources :gallery_photos, :controller => 'l/gallery_photos'
    end
        CONTENT
        log :route, "resources :galleries"
        inject_into_file 'config/routes.rb', 
          routing_code, 
          :before => %r{^\s*resources :users}, 
          :verbose => false
      end

      def add_search_results_in_search_action # :nodoc:
        inject_into_file File.join(destination_root, 'app/controllers/application_controller.rb'), 
          "    @galleries = L::Gallery.search(params[:q])\n", 
          :after => "def search\n"
      end

      def add_link_in_menu # :nodoc:
        link = <<-LINK
  <%= admin_menu_link(:galleries) if current_user.has_role? :admin %>
        LINK
        inject_into_file File.join(destination_root, 'app/views/l/admins/partials/_header.erb'), link, :before => "</div>\n<div id=\"submenu\">"
      rescue
        log :skip, "Adding galleries to menu"
      end

    end
  end
end
