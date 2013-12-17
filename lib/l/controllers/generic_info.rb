module L
  module Controllers
    # Moduł dodający metodę do generowania wiadomości (alert, notice) w kontrolerze
    module GenericInfo
      extend ActiveSupport::Concern

      def info(*args)
        options = args.extract_options!

        modules = self.class.name.deconstantize.split("::").map(&:downcase)
        key = :"#{modules.join('.')}.#{controller_name}.#{action_name}.#{args.join('.')}"

        options[:default] = [ 
          :"helpers.status.#{action_name}.#{args.join('.')}",
          :"helpers.status.#{args.join('.')}",
          args.join(' ').humanize
        ]

        I18n.t(key, options)
      end
    end
  end
end
