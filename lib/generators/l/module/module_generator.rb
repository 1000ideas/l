# encoding: utf-8

module L
  module Generators # :nodoc:
    require 'l/generators/actions'

    # Generator tworzący customowy moduł dopasowany do CMS-a
    #
    # Tworzone są kontrolery, modele, migracje i widoki. Dodawany jest routing.
    # Wymaga podania argumentu NAME (w liczbie pojedynczej)
    #
    # * *Argumenty*
    #
    #   - +attributes+ - lista par +nazwa+:+typ+, gdzie +nazwa+ jest dowolną nazwą
    #     pola, a +typ+ jest typem pola i jest taki jak w generatorze scaffold oraz
    #     dodatkowo może być równy +file+ gdy pole ma być załącznikiem +Paperclip+
    #     lub +tinymce_theme+ (gdzie +theme+ jest nazwą szablonu TinyMCE:
    #     fileupload, advance, simple) jeśli pole ma być polem tekstowym edytowanym
    #     w edytorze TinyMCE
    #
    # * *Parametry*:
    #
    #   - +--orm+ - Nazwa klasy ORM
    #   - +--searchable+ - lista nazw pól które mają być przeszykiwane w
    #     generowanej metodzie +search+ dla tworzonego modułu
    #   - +--interactive+, +-i+ - Interaktywnu tryb generatora, pozwala wprowadzić
    #     tłumaczenia etykiet linków, tytułów stron i nazw atrybutów tworzonego
    #     modułu.
    class ModuleGenerator < ::Rails::Generators::NamedBase
      include L::Generators::Actions

      argument :attributes, :required => false, :type => :array, :default => [], :banner => "field:type field:type", desc: 'Tak jak w scaffold + dodatkowe typy pól: file, tinymce_(theme)'
      class_option :orm, :default => "active_record"
      class_option :searchable, :type => :array, :default => [], :desc => 'Argumenty które mają być wyszukiwane', :banner => 'field field ...'
      class_option :interactive, aliases: '-i', type: :boolean, default: false, desc: "Tryb interaktywny"

      desc "Generator tworzy customowy modul dostosowany do cmsa " <<
        "(tworzy model, kontroler, migracje, widoki, dodaje routing). " <<
        "Wymaga podania argumentu NAME (w liczbie pojedynczej).\n"

      def self.source_root # :nodoc:
        @source_root ||= File.join(File.dirname(__FILE__), 'templates')
      end

      def generate_model # :nodoc:
        invoke :model, model_args, migration: true
      end

      def insert_file_fields_to_migration # :nodoc:
        return if migration_file.nil?

        file_attributes.each do |a|
          inject_into_file migration_file, "t.attachment :#{a.name}\n    ",
            before: "t.string :#{a.name}"
          comment_lines migration_file, %r{t\.string :#{a.name}}
        end
      end

      def insert_has_attached_file # :nodoc:
        return unless model_exists?

        file_attributes.each do |a|
          inject_into_file model_path,
            "  has_attached_file :#{a.name}\n  validates_attachment :#{a.name}, content_type: {content_type: /.*/}\n",
              after: "ActiveRecord::Base\n"
        end
      end

      def add_search_method_to_model # :nodoc:
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

      def create_controller_files # :nodoc:
        template 'controller.rb', controller_path
        template 'admin_controller.rb', admin_controller_path
      end

      def add_abilities
        inject_into_file 'app/models/ability.rb',
         "      can :manage, #{class_name}\n",
         after: %r{^\s*if user\.(?:has_role\?\s+:)?admin\??\n}
      end

      def add_routes # :nodoc:
        routing_code = "resources :#{plural_name}, except: [:show]"
        inject_into_file 'config/routes.rb',
          "      #{routing_code} do\n        post :selection, on: :collection\n      end\n",
          after: %r{^\s*scope module: :admin.*\n},
          verbose: false

        log :route, routing_code
      end

      def add_front_routes # :nodoc:
        routing_code = "resources :#{plural_name}, only: [:index, :show]"
        inject_into_file 'config/routes.rb',
          "  #{routing_code}\n",
          before: %r{^\s*scope path: 'admin'.*\n},
          verbose: false

        log :route, routing_code
      end

      def create_view_folder # :nodoc:
        empty_directory File.join("app/views", controller_file_path)
        empty_directory File.join("app/views/admin", controller_file_path)
      end

      def copy_view_files # :nodoc:
        available_admin_views.each do |view|
          filename = "#{view}.html.erb"
          template filename, File.join("app/views/admin", controller_file_path, filename)
        end
        template "front_index.html.erb", File.join("app/views", controller_file_path, "index.html.erb")
        template "front_show.html.erb", File.join("app/views", controller_file_path, "show.html.erb")
      end

      def add_translations # :nodoc:
        defaults = I18n.t('defaults', locale: :pl).stringify_keys
        defaults.keys.each do |k|
          defaults[k].stringify_keys!
        end

        trans = {
          'admin' => {
            "#{plural_table_name}" => {
              'submenu' => {
                'new' => "Add #{singular_table_name}",
                'index' => "List #{plural_table_name}"
              },
              'new' => {
                'title' => "Add #{singular_table_name}"
              },
              'index' => {
                'title' => "#{plural_name.capitalize}"
              },
              'edit' => {
                'title' =>  "Edit #{singular_table_name}"
              }
            }.merge(defaults)
          },
          "#{plural_table_name}" => {
            'index' => {
              'title' => plural_name.capitalize
            },
            'show' => {
              'title' => name.capitalize
            }
          }
        }

        attr_hash =  Hash[attributes.map { |at| [at.name, at.human_name] } ]

        trans['menu'] = {"#{plural_name.downcase}" => plural_name.capitalize}
        trans['activerecord'] = { 'attributes' => {"#{name.downcase}" => attr_hash} }

        I18n.available_locales.each do |locale|
          translations_file name, trans, locale
        end
      end

      def add_admin_menu_link
        link = "<%= admin_menu_link(:#{plural_table_name}) if current_user.admin? %>"
        inject_into_file "app/views/layouts/l/admin.html.erb",
          "          #{link}\n",
          before: %r{^\s*<%= link_to.*root_path.*right.*$},
          verbose: false

        log :insert, link

      end

      private

      def available_admin_views
        %w(index edit new _filter _form _submenu _tooltip)
      end

      def model_args
        ARGV.map do |arg|
          arg.gsub(%r{:file(:|$)}, ":string\\1").gsub(%r{:tinymce[a-z_]*(:|$)}, ":text\\1")
        end
      end

      def file_attributes
        @file_attr ||= attributes.select{ |a| a.type == :file }
      end

      def tinymce_attributes
        @tiny_attr ||= attributes.select{ |a| a.type.to_s.match /^tinymce_.*$/ }
      end

      def used_tinymce_classes
        tinymce_attributes.map do |attr|
          attr.type.match /^tinymce_(.*)$/
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

      def admin_controller_path
        @admin_controller_path ||= File.join("app", "controllers", "admin", "#{controller_file_path}_controller.rb")
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

