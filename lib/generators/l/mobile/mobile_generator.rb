# encoding: utf-8

module L
  module Generators

    # Generator tworzący mobily moduł aplikacji
    #
    # Dodawany jest wpis w +routes.rb+ przekierowujący zapytania w subdomenie
    # +m+ na kontroler Mobile. Dodwany jest before filter w kontrolerze
    # Application przekierowujący na mobilny kontroller. Kopiowanie widoków
    # mobilnych.
    #
    class MobileGenerator < ::Rails::Generators::Base

      desc "Generator odpowiedzialny za przygotowanie mobilnego kontrolera aplikacji," <<
        "kopiowanie widoków i dodanie routes'ów"

      def self.source_root # :nodoc:
        @source_root ||= File.join(File.dirname(__FILE__), '../../../../app')
      end

      def add_routes # :nodoc:
        route <<-CONTENT
  constraints :subdomain => 'm' do
    root :to => 'l/mobile#index'
  end
        CONTENT
      end

      def insert_before_filter # :nodoc:
        inject_into_file 'app/controllers/application_controller.rb', 
          "  before_filter :mobile_subdomain\n",
          after: "ActionController::Base\n",
          verbose: false

        mobile_subdomain_method = <<-CONTENT
  def mobile_subdomain
    if not request.subdomains.empty? and request.subdomains[0] == 'm'
      redirect_to root_path
    end
  end
        CONTENT

        inject_into_file 'app/controllers/application_controller.rb',
          mobile_subdomain_method,
          after: "private\n",
          verbose: false

        log :insert, 'before_filter :mobile_subdomain'
      end

      def copy_views # :nodoc:
        %w{index error404 error401}.each do |file|
          copy_file "views/l/mobile/#{file}.html.erb",
            "app/views/l/mobile/#{file}.html.erb"
        end
      end
    end
  end
end
