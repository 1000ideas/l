module L
  module Generators
    class ModuleGenerator < Rails::Generators::Base

      def intro
        say "Custom Module generator"
      end
    end
  end
end

