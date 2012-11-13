# encoding: utf-8

module L
  module Generators
    require 'l/generators/actions'

    class ModuleGenerator < ::Rails::Generators::NamedBase
      include L::Generators::Actions

      argument :attributes, :required => false, :type => :array, :default => [], :banner => "field:type field:type", desc: 'Tak jak w scaffold + dodatkowe typy pól: file, tiny_mce_(theme)'
      class_option :orm, :default => "active_record"
      class_option :searchable, :type => :array, :default => [], :desc => 'Argumenty które mają być wyszukiwane', :banner => 'field field ...'
      class_option :interactive, aliases: '-i', type: :boolean, default: false, desc: "Tryb interaktywny"

      desc "Generator tworzy customowy modul dostosowany do cmsa " <<
        "(tworzy model, kontroler, migracje, widoki, dodaje routing). " <<
        "Wymaga podania argumentu NAME (w liczbie pojedynczej).\n"

      def self.source_root
        @source_root ||= File.join(File.dirname(__FILE__), 'templates')
      end

      def generate_model
        invoke :model, model_args, :migration => true
      end

      def insert_file_fields_to_migration
        return if migration_file.nil?

        file_attributes.each do |a|
          inject_into_file migration_file, "t.attachment :#{a.name}\n    ",
            before: "t.string :#{a.name}"
          comment_lines migration_file, %r{t\.string :#{a.name}}
        end
      end

      def insert_has_attached_file
        return unless model_exists?

        file_attributes.each do |a|
          inject_into_file model_path, 
            "  has_attached_file :#{a.name}, styles: { medium: '300x300>', thumb: '100x100#' }\n",
            :after => "ActiveRecord::Base\n"
        end
      end

      def add_search_method_to_model
        unless options.searchable.blank? or not model_exists?
          where_clause = options.searchable.map {|f| "#{f} LIKE :pattern" } .join(' OR ')
          search_method = <<-CONTENT
  def self.search(phrase)
    find(:all, :conditions => ['#{where_clause}', {:pattern => "%\#{phrase}%"}])
  end
          CONTENT
          inject_into_class model_path, name.capitalize, search_method
        
          inject_into_file 'app/controllers/application_controller.rb', 
            "    @#{plural_name.downcase} = #{name.capitalize}.search(params[:q])\n", 
            after: "def search\n"
        end
      end

      check_class_collision :suffix => "Controller"
      
      def create_controller_files
        template 'controller.rb', controller_path
      end

      def add_routes
        routing_code = "resources :#{plural_name}" 
        log :route, routing_code
        inject_into_file 'config/routes.rb', "  #{routing_code}\n", :before => "resources :users", :verbose => false
      end

      def create_view_folder
        empty_directory File.join("app/views", controller_file_path)
      end

      def copy_view_files
        available_views.each do |view|
          filename = "#{view}.html.erb"
          template filename, File.join("app/views", controller_file_path, filename)
        end
      end

      def add_translations
        menu_names = {}
        if options.interactive
          require 'highline/import'

          say "Wprowadź polskie tłumaczenia:"
          menu_names = {
            :menu => ask("Etykieta przycisku w menu głównym: ") {|q| q.default = "#{plural_name}" }
          }
          
          say "Etykiety przycisków w podmenu:"
          menu_names.merge!(
            :sub_new => ask("# Dodaj nowy element:") { |q| q.default = "Dodaj #{name}" },
            :sub_idx => ask("# Lista elementów:") {|q| q.default = "Lista #{plural_name}" }
          )

          say "Tytuły stron modułu:"
          menu_names.merge!(
            :new => ask("# Tytuł strony dodawania elementu:") { |q| q.default = "Dodawanie #{name}" },
            :idx => ask("# Tytuł strony listy  elementów:") {|q| q.default = "#{plural_name}" },
            :edt => ask("# Tytuł strony edycji elementu:") {|q| q.default = "Edycja #{name}" }
          )
        end

        trans = { "#{plural_name.downcase}" => {
              'submenu' => {
                'new' => menu_names[:sub_new] || "Dodaj #{name}",
                'index' => menu_names[:sub_idx] || "Lista #{plural_name}"
              },
              'new' => {
                'title' => menu_names[:new] || "Dodawanie #{name}"
              },
              'index' => {
                'title' => menu_names[:idx] || "#{plural_name}"
              },
              'edit' => {
                'title' =>  menu_names[:edt] || "Edycja #{name}"
              }
            }}

        if options.interactive
          say "Tłumaczenia atrybutów modelu:"
          attr_names = attributes.map do |at| 
            hname = ask("# #{at.name}:") {|q| q.default = at.human_name }
            [at.name, hname]
          end
          attr_hash =  Hash[attr_names]
        else
          attr_hash =  Hash[attributes.map { |at| [at.name, at.human_name] } ]
        end

        trans['menu'] = {"#{plural_name.downcase}" => menu_names[:menu] || plural_name.capitalize}
        trans['activerecord'] = { 'attributes' => {"#{name.downcase}" => attr_hash} }

        translations_file name, trans, :pl
      end

      def add_link_in_menu
        pld = plural_name.downcase
        link = <<-LINK
<%= link_to t('menu.#{pld}'), #{pld}_path, :class => "\#{controller_name == '#{pld}' ? 'active' : ''}" if current_user.has_role? :admin %>
        LINK
        inject_into_file File.join(destination_root, 'app/views/l/admins/partials/_header.erb'), link, :before => "</div>\n<div id=\"submenu\">"
      rescue
        log :skip, "Adding link in admin"
      end

      private

      def available_views
        %w(index edit show new _filter _form _submenu _tooltip)
      end

      def model_args
        ARGV.map do |arg|
          arg.gsub(%r{:file(:|$)}, ":string\\1").gsub(%r{:tiny_mce[a-z_]*(:|$)}, ":text\\1")
        end
      end

      def file_attributes
        @file_attr ||= attributes.select{ |a| a.type == :file }
      end

      def tiny_mce_attributes
        @tiny_attr ||= attributes.select{ |a| a.type.to_s.match /^tiny_mce_.*$/ }
      end

      def used_tiny_mce_classes
        tiny_mce_attributes.map do |attr|
          attr.type.match /^tiny_mce_(.*)$/
          $1.to_sym
        end
      end

      def migration_file
        @mf ||= Dir["#{::Rails.root}/db/migrate/*.rb"].select do |path|
          path.match /create_#{plural_table_name}/
        end.first
      end

      def model_path
        @model_file ||= "app/models/#{singular_table_name}.rb"
      end

      def controller_path
        @controller_path ||= File.join("app", "controllers", "#{controller_file_path}_controller.rb")
      end

      def mobile_controller_path
        @mobile_controller_path ||= File.join("app", "controllers", "mobile", "#{controller_file_path}_controller.rb")
      end

      def controller_file_path
        @controller_file_path ||= (controller_class_path + [controller_file_name]).join('/')
      end

      def controller_class_path
        @class_path
      end

      def controller_file_name
        @controller_file_name ||= file_name.pluralize
      end

      def controller_class_name
        @controller_class_name ||= (controller_class_path + [controller_file_name]).
          map!{ |m| m.camelize }.
          join('::')
      end


      def model_exists?
        ::Rails.root.join(model_path).file?
      end

    end
  end
end

