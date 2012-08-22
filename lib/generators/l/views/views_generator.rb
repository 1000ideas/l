# encoding: utf-8

module L
  module Generators

    class ViewsGenerator< ::Rails::Generators::Base

      @@views_list = %w{layouts partials admins users}

      class_option :except,
        type: :array,
        default: [],
        desc: "Nie kopiuj wybranych widoków. Dostepne widoki: #{@@views_list.join ', '}."

      desc "Generator kopiujący widoki lazy_programmera. Nadpisują one widoki z gema," <<
        "więc można w nich wprowadzać zmiany"

      def self.source_root
        @source_root ||= File.join(File.dirname(__FILE__), '../../../../app')
      end

      def copy_views
        (@@views_list - options[:except]).each do |view|
          directory "views/l/#{view}", "app/views/l/#{view}"
        end
      end
    end
  end
end

