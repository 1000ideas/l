module L
  module Rails
    class Engine < ::Rails::Engine
      initializer "precompile", :group => :all do |app|
        app.config.assets.precompile += ["jquery.js", "jquery_ujs.js", "admin.js", "admins.js", "admins.css", 'admin/admin_login.css']
      end

      initializer "helper" do |app|
        ActiveSupport.on_load(:action_view) do
          include L::LightboxHelper
        end
      end
    end
  end
end
