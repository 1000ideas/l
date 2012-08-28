module L
  module Generators
    module Actions

      def load_template(source)
        source  = File.expand_path(find_in_source_paths(source.to_s))
        context = instance_eval('binding')
        ERB.new(::File.binread(source), nil, '-', '@output_buffer').result(context)        
      end

      def inject_template_into_file(dest, source, options = {})
        tmpl = load_template(source)
        inject_into_file dest, tmpl, options
      end

      def translations(file, trans, path = 'pl')
        idt = path.split('.').size
        indent = "  " * idt
        after = path.split('.').zip(1..idt).map do |p, n|
          if n < idt
            p + ":.*\n" + "  " * n
          else
            p + ":\n"
          end
        end.join('')
        after_regex = /#{after}/m
        translation = trans.to_yaml.gsub("\n", "\n#{indent}")[4..-1].rstrip + "\n"
        translation = translation.encode 'ascii-8bit', undef: :replace
        inject_into_file file, translation, after: after_regex, verbose: false
        log :translations, file
      end

      def orm_class
        @orm_class ||= begin
          # Raise an error if the class_option :orm was not defined.
          unless self.class.class_options[:orm]
            raise "You need to have :orm as class option to invoke orm_class and orm_instance"
          end

          begin
            "#{options[:orm].to_s.classify}::Generators::ActiveModel".constantize
          rescue NameError => e
            ::Rails::Generators::ActiveModel
          end
        end
      end

      def orm_instance(name=singular_table_name)
        @orm_instance ||= @orm_class.new(name)
      end

      def field_options(attr)
        if attr.type.to_s.match %r{^tiny_mce_([a-z_]*)$}
          opt = {
            :class => "mce#{$1.capitalize}",
            :cols => 70,
            :rows => 5
          }
          ", " + opt.to_s[1..-2]
        elsif attr.field_type == :text_area
          opt = {
            :cols => 70,
            :rows => 5
          }
          ", " + opt.to_s[1..-2]
        else
          ""
        end
      end

      def field_type(attr)
        if attr.type == :file
          :file_field
        elsif attr.type =~ /^tiny_mce_/
          :text_area
        else
          attr.field_type
        end
      end

      def field_class(attr)
        cls = ['field']
        cls << 'field_with_date' if [:date, :datetime, :timestamp].include? attr.type
        cls << 'field_with_time' if attr.type == :time
        cls << 'field_with_textarea' if attr.type =~ /^tiny_mce_/
        cls.join ' '
      end
    end
  end
end

