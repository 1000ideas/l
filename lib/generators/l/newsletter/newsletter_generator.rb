# encoding: utf-8
module L
  module Generators
    require 'rails/generators/active_record'
    require 'l/generators/actions'

    # Generator tworzący moduł newslettera.
    #
    # Tworzona jest migracja dla modelu NewsletterMail. Generowany jest mailer
    # Newsletter z dwiema metodami <tt>send_mail(adressee, content)</tt> oraz
    # <tt>confirmation(newsletter_mail)</tt>. Kopiowane są widoki modułu i szablony
    # mail. Dodawany jest routing oraz link w menu panelu administracyjnego.
    #
    class NewsletterGenerator < ::Rails::Generators::Base
      include L::Generators::Actions
      include ::Rails::Generators::Migration

      desc "Tworzy modul newslettera (mailer newsletter oraz model i kontroler"<<
        "newsletter mails), potrzebne migracje, kopiuje widoki" <<
        "oraz dodaje routing."

      def self.source_root # :nodoc:
        @source_root ||= File.join(File.dirname(__FILE__), 'templates')
      end

      class << self
        delegate :next_migration_number, to: ActiveRecord::Generators::Base
      end

      def create_migration_file # :nodoc:
        migration_template 'newsletter_mails.rb', 'db/migrate/create_newsletter_mails.rb'
      end

      def invoke_newsletter_mailer # :nodoc:
        case behavior
        when :invoke
          generate :mailer, 'newsletter'
        when :revoke
          destroy :mailer, 'newsletter'
        end
      end

      def inject_methods_into_newsletter_mailer # :nodoc:
        metody = <<-CONTENT
  def send_mail(adressee, content)
    @content = content
    mail :to => adressee
  end

  def confirmation(newsletter_mail)
    @mail = newsletter_mail
    mail :to => newsletter_mail.mail
  end\n
CONTENT
        inject_into_class newsletter_mailer_path, 'Newsletter', metody
      end

      def copy_newsletter_mails_views # :nodoc:
        directory "../../../../../app/views/l/newsletter_mails", "app/views/l/newsletter_mails"
        directory "../../../../../app/views/l/admin/newsletter_mails", "app/views/l/admin/newsletter_mails"
        copy_file "_newsletter.erb", "app/views/l/partials/_newsletter.erb"
      end

      def copy_newsletter_mailer_views # :nodoc:
        directory "newsletter", "app/views/newsletter"
      end

      def add_newsletter_route # :nodoc:
        routing_code = <<-CONTENT

      resources :newsletter_mails, only: [:index, :destroy] do
        collection do
          get :unconfirmed, action: :index, defaults: {unconfirmed: true}
          get :send_mail, action: :send_mail_edit
          post :send_mail
          constraints(lambda {|req| req.params.has_key?(:ids)}) do
            delete :bulk_destroy, action: :selection, defaults: {bulk_action: :destroy}
            put :bulk_confirm, action: :selection, defaults: {bulk_action: :confirm}
          end
        end
        put :confirm, on: :member
      end

        CONTENT

        inject_into_file 'config/routes.rb',
          routing_code,
          after: %r{^\s*scope module: 'l/admin'.*\n},
          verbose: false

        routing_code = <<-CONTENT

  resources :newsletter_mails,  module: :l, only: [:create] do
    get :confirm, on: :collection
  end

        CONTENT

        inject_into_file 'config/routes.rb',
          routing_code,
          before: %r{^\s*scope path: 'admin'},
          verbose: false


        log :route, "resources :newsletter_mails"
      end

      protected

      def newsletter_mailer_exists? # :nodoc:
        File.exists?(File.join(destination_root, newsletter_mailer_path))
      end

      def newsletter_mailer_path # :nodoc:
        @newsletter_mailer_path ||= File.join("app", "mailers", "newsletter.rb")
      end

    end
  end
end
