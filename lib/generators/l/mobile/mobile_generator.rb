# encoding: utf-8

module L
  module Generators

    class MobileGenerator < ::Rails::Generators::Base

      desc "Generator odpowiedzialny za przygotowanie mobilnego kontrolera aplikacji," <<
        "kopiowanie widoków i dodanie routes'ów"

      def self.source_root
        @source_root ||= File.join(File.dirname(__FILE__), '../../../../app')
      end

      def add_routes
        route <<-CONTENT
  constraints :subdomain => 'm' do
    root :to => 'l/mobile#index'
  end
        CONTENT
      end

      def insert_before_filter
        inject_into_file 'app/controllers/application_controller.rb', 
          "  before_filter :mobile_subdomain\n",
          after: "ActionController::Base\n"

        mobile_subdomain_method = <<-CONTENT
  def mobile_subdomain
    if not request.subdomains.empty? and request.subdomains[0] == 'm'
      redirect_to root_path
    end
  end
        CONTENT

        inject_into_file 'app/controllers/application_controller.rb',
          mobile_subdomain_method,
          after: "private\n"
      end

      def copy_views
        %w{index error404 error401}.each do |file|
          copy_file "views/l/mobile/#{file}.html.erb",
            "app/views/l/mobile/#{file}.html.erb"
        end
      end
    end
  end
end
