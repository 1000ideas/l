# encoding: utf-8

module L
  module Generators

    # Generator kopiujący widoki podstawowej aplikacji Lazego.
    class ViewsGenerator< ::Rails::Generators::Base

      @@views_list = %w{partials admin/users}

      class_option :except,
        type: :array,
        default: [],
        desc: "Nie kopiuj wybranych widoków. Dostepne widoki: #{@@views_list.join ', '}."

      desc "Generator kopiujący widoki lazy_programmera. Nadpisują one widoki z gema," <<
        "więc można w nich wprowadzać zmiany"

      def self.source_root # :nodoc:
        @source_root ||= File.join(File.dirname(__FILE__), '../../../../app')
      end

      def copy_views # :nodoc:
        except = options[:except] || []

        (@@views_list - except).each do |view|
          directory "views/l/#{view}", "app/views/l/#{view}"
        end

        unless except.include? 'layouts'
          directory "views/layouts/l", "app/views/layouts/l"
        end
      end
    end
  end
end

