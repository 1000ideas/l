# encoding: utf-8
module L
  module Generators
    require 'rails/generators/active_record'
    require 'l/generators/actions'

    class NewsletterGenerator < ::Rails::Generators::Base
      include L::Generators::Actions
      include ::Rails::Generators::Migration

      desc "Tworzy modul newslettera (mailer newsletter oraz model i kontroler"<<
        "newsletter mails), potrzebne migracje, kopiuje widoki" <<
        "oraz dodaje routing."

      def self.source_root
        @source_root ||= File.join(File.dirname(__FILE__), 'templates')
      end

      class << self
        delegate :next_migration_number, to: ActiveRecord::Generators::Base
      end

      def create_migration_file
        migration_template 'newsletter_mails.rb', 'db/migrate/create_newsletter_mails.rb'
      end

      def invoke_newsletter_mailer
        case behavior
        when :invoke
          generate :mailer, 'newsletter'
        when :revoke
          destroy :mailer, 'newsletter'
        end
      end

      def inject_methods_into_newsletter_mailer
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

      def copy_newsletter_mails_views
        directory "../../../../../app/views/l/newsletter_mails", "app/views/l/newsletter_mails"
        copy_file "_newsletter.erb", "app/views/l/partials/_newsletter.erb"
      end

      def copy_newsletter_mailer_views
        directory "newsletter", "app/views/newsletter"
      end

      def add_newsletter_route
        routing_code = <<-CONTENT
  resources :newsletter_mails, controller: 'l/newsletter_mails', only: [:index, :create, :destroy] do
    collection do
      get :send_mail, action: :send_mail_edit
      post :send_mail
      get :confirm
    end
  end
        CONTENT

        inject_into_file 'config/routes.rb', 
          routing_code, 
          :before => "resources :users", 
          :verbose => false
        log :route, "resources :newsletter_mails"
      end

      def add_link_in_menu
        link = <<-LINK
<%= link_to t('menu.newsletter'), newsletter_mails_path, class: "\#{controller_name == 'newsletter_mails' ? 'active' : ''}" if current_user.has_role? :admin %>"
        LINK
        inject_into_file 'app/views/l/admins/partials/_header.erb',
          link, 
          :before => "</div>\n<div id=\"submenu\">"
      rescue
        log :skip, "Adding link to admin menu"

      end

      protected

      def newsletter_mailer_exists?
        File.exists?(File.join(destination_root, newsletter_mailer_path))
      end

      def newsletter_mailer_path
        @newsletter_mailer_path ||= File.join("app", "mailers", "newsletter.rb")
      end

    end
  end
end
