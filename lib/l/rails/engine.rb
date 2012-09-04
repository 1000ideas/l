module L
  module Rails
    class Engine < ::Rails::Engine
      initializer "precompile", :group => :all do |app|
        app.config.assets.precompile += ["admins.js", "admins.css", 'admin/admin_login.css']
      end
    end
  end
end
