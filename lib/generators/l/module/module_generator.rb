# encoding: utf-8

module L
  module Generators # :nodoc:
    require 'l/generators/actions'
    require 'rails/generators/active_record'
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
      include ::Rails::Generators::Migration

      argument :attributes, :required => false, :type => :array, :default => [], :banner => "field:type field:type", desc: 'Tak jak w scaffold + dodatkowe typy pól: file, tinymce_(theme)'
      class_option :orm, :default => "active_record"
      class_option :searchable, :type => :array, :default => [], :desc => 'Argumenty które mają być wyszukiwane', :banner => 'field field ...'
      class_option :interactive, aliases: '-i', type: :boolean, default: false, desc: "Tryb interaktywny"
      class_option :with_draft,aliases: '-with_draft', type: :boolean, default: false, desc: "tworzenie szkiców dla modułu"

      desc "Generator tworzy customowy modul dostosowany do cmsa " <<
        "(tworzy model, kontroler, migracje, widoki, dodaje routing). " <<
        "Wymaga podania argumentu NAME (w liczbie pojedynczej).\n"

      class << self
        delegate :next_migration_number, :to => ActiveRecord::Generators::Base
      end
      
      def self.source_root # :nodoc:
        @source_root ||= File.join(File.dirname(__FILE__), 'templates')
      end

      def generate_model # :nodoc:
        
        if options.with_draft
          migration_template('module_draft_migration.rb',
                 File.join('db', 'migrate', "create_#{singular_table_name}_drafts.rb"))
          invoke :model, model_args, migration: true
          
          
        else
          invoke :model, model_args, migration: true
        end
      end

      def insert_file_fields_to_migration # :nodoc:
        return if migration_file.nil?

        file_attributes.each do |a|
          inject_into_file migration_file, "t.attachment :#{a.name}\n    ",
            before: "t.string :#{a.name}"
          comment_lines migration_file, %r{t\.string :#{a.name}}
        end
      end

      def nullable_deleted_at_column
        return if migration_file.nil?

        inject_into_file migration_file,
          ", null: true",
          after: 't.datetime :deleted_at'
      end

      def insert_has_attached_file # :nodoc:
        return unless model_exists?

        file_attributes.each do |a|
          inject_into_file model_path,
            "  has_attached_file :#{a.name}\n  validates_attachment :#{a.name}, content_type: {content_type: /.*/}\n",
              after: "ActiveRecord::Base\n"
        end
      end

      def add_filters_to_model
        return unless model_exists?

        inject_into_file model_path,
          %(  scope :filter_by_created_before, lambda {|date| where("`created_at` < ?", Date.parse(date)) }\n),
            after: "ActiveRecord::Base\n"
        inject_into_file model_path,
          %(  scope :filter_by_created_after, lambda {|date| where("`created_at` > ?", Date.parse(date)) }\n),
            after: "ActiveRecord::Base\n"

        attributes.each do |attribute|
          field_name = if attribute.type == :file
            "#{attribute.name}_file_name"
          else
            attribute.name
          end
          inject_into_file model_path,
            "  scope :filter_by_#{field_name}, lambda {|value| where(#{field_name}: value) }\n",
              after: "ActiveRecord::Base\n"

        end
      end

      def add_search_method_to_model # :nodoc:
        if model_exists?
          inject_into_class model_path,
            name.capitalize,
            "  acts_as_paranoid\n"

          if options.searchable.any?
            where_clause = options.searchable.map {|f| "#{f} LIKE :pattern" }.join(' OR ')
            inject_into_class model_path,
              name.capitalize,
              %Q[scope :search, lambda {|phrase| where("#{where_clause}", {:pattern => "%\#{phrase}%"})}\n]


            inject_into_file 'app/controllers/application_controller.rb',
              "    @#{plural_name.downcase} = #{name.capitalize}.search(params[:q])\n",
              after: "def search\n"
          end
        end
      end

      def add_public_activity_include
        if model_exists?
          inject_into_class model_path,
            name.capitalize,
            "  include PublicActivity::Common\n"

        end
      end


      check_class_collision suffix: "Controller"

      def create_controller_files # :nodoc:
        if options.with_draft
          template 'draft_controller.rb', controller_path
          template 'admin_draft_controller.rb', admin_controller_path
        else
          template 'controller.rb', controller_path
          template 'admin_controller.rb', admin_controller_path
        end
      end

      def add_abilities
        if options.with_draft
          cancanoption = "      can :manage, #{class_name}\n can :manage, #{class_name}::Draft\n"
        else
          cancanoption = "      can :manage, #{class_name}\n"
        end
        
        inject_into_file 'app/models/ability.rb',
         cancanoption,
         after: %r{^\s*if user\.(?:has_role\?\s+:)?admin\??\n}
      end

      def add_routes # :nodoc:
        routing_code = "resources :#{plural_name}, except: [:show]"
        if options.with_draft

          _routing_code = <<-CONTENT
          resources :#{plural_name}, except: [:show] do
            member do
              get :edit_draft
              put :update_draft
            end
            collection do
              constraints(lambda {|req| req.params.has_key?(:ids)}) do
                delete :bulk_destroy, action: :selection, defaults: {bulk_action: :destroy}
              end
            end
          end
          CONTENT
        else
          _routing_code = <<-CONTENT
          resources :#{plural_name}, except: [:show] do
            collection do
              constraints(lambda {|req| req.params.has_key?(:ids)}) do
                delete :bulk_destroy, action: :selection, defaults: {bulk_action: :destroy}
              end
            end
          end
          CONTENT
        end
        inject_into_file 'config/routes.rb',
          _routing_code,
          after: %r{^\s*scope module: :admin.*\n},
          verbose: false

        log :route, routing_code
      end

      def add_front_routes # :nodoc:
        routing_code = "resources :#{plural_name}, only: [:index, :show]"
        if options.with_draft
          routing_code = <<-CONTENT 
          resources :#{plural_name}, only: [:index, :show] do
            get :show_draft
          end
          CONTENT
        end
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
        %w(index new edit create update).each do |name|
          template "#{name}.js.coffee", File.join("app/views/admin", controller_file_path, "#{name}.js.coffee")
        end
        if options.with_draft
          %w(edit_draft update_draft).each do |name|
          template "#{name}.js.coffee", File.join("app/views/admin", controller_file_path, "#{name}.js.coffee")
        end
        end
        template "_object.html.erb", File.join("app/views/admin", controller_file_path, "_#{singular_table_name}.html.erb")
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
                'index' => "List #{plural_table_name}",
                'destroy' => "Destroy selected #{plural_table_name}",
                'destroy_confirm' => "Destroying selected #{plural_table_name}, sure?"
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
        link = <<-CONTENT
    <li><%= link_to( t('.#{plural_table_name}'), admin_#{index_helper}_path) %></li>
    <li class="spacer"></li>
CONTENT
        inject_into_file "app/views/l/admin/_menu.html.erb",
          "\n#{link}",
          after: %r{^\s*<ul class="root">},
          verbose: false
        log :insert, link
      end

      private

      def available_admin_views
        options.with_draft ? %w(index edit new _filter _form _edit_draft_form _submenu _list) : %w(index edit new _filter _form _submenu _list)
      end

      def model_args
        
        args = ARGV.map do |arg|
          arg.gsub(%r{:file(:|$)}, ":string\\1").gsub(%r{:tinymce[a-z_]*(:|$)}, ":text\\1")
        end
        args.push('deleted_at:datetime:index') unless args.any? { |arg| /^deleted_at:/ === arg }
        args
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

