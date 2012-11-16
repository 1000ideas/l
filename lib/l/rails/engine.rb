module L
  module Rails # :nodoc:
    class Engine < ::Rails::Engine # :nodoc:
      initializer "precompile", :group => :all do |app|
        app.config.assets.precompile += ["jquery.js", "jquery_ujs.js", "admin.js", "admins.js", "admins.css", 'admin/admin_login.css']
      end

      initializer "helper" do |app|
        ActiveSupport.on_load(:action_view) do
          include L::LazyHelper
          include L::FormHelper
          include L::FilterHelper
          include L::LightboxHelper
        end
      end

      initializer "string_extension" do |app|
        String.class_eval do
          include L::StringExtension
        end
      end
    end
  end
end
