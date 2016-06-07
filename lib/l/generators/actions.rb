# encoding: utf-8

module L
  module Generators
    # Moduł rozszerzający możliwości generatorów
    module Actions

      # Wczytaj i sparsuj szablon z pliku
      #
      # * *Argumenty*:
      #   
      #   - +source+ -> scieżka do pliku źródłowego szablonu
      #
      # * *Zwraca*:
      #
      #   Sparsowany szablon
      def load_template(source)
        source  = File.expand_path(find_in_source_paths(source.to_s))
        context = instance_eval('binding')
        ERB.new(::File.binread(source), nil, '-', '@output_buffer').result(context)        
      end

      # Wczytaj, sparsuj i wstaw szablon do pliku
      #
      # * *Argumenty*:
      #   
      #   - +dest+ -> scieżka do docelowego pliku
      #   - +source+ -> ścieżka do pliku z szablonem
      #   - +options+ -> opcje, takie jak w funckcji +inject_into_file+
      def inject_template_into_file(dest, source, options = {})
        tmpl = load_template(source)
        inject_into_file dest, tmpl, options
      end

      # Wstaw tłumaczenia do pliku
      #
      # * *Argumenty* :
      #   
      #   - +file+ -> nazwa pliku z tłumaczeniami
      #   - +trans+ -> hash z drzewem tłumaczeń
      #   - +path+ -> ścieżka w drzewie tłumaczeń do której podpiąc tłumaczenie,
      #     domyślnie 'pl'
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

      # Utwórz plik z tłumaczeniami
      #
      # * *Argumenty* :
      #   
      #   - +name+ -> nazwa tłumaczonego modułu
      #   - +trans+ -> drzewo tłumaczeń
      #   - +lang+ -> język tłumaczeń
      #
      def translations_file(name, trans, lang = :pl)
        file = ::Rails.root.join('config', 'locales', "module_#{name.downcase}.#{lang}.yml")
        create_file file, verbose: false
        log :translations, file.relative_path_from(::Rails.root).to_s

        File.open(file, 'w+') do |f|
          f.write({lang.to_s => trans}.to_yaml)
        end if behavior == :invoke
      end

      # Wywołaj +rails destroy+
      #
      # * *Argumenty* :
      #
      #   - +what+ -> nazwa generatora do zniszczenia
      #   - +args+ -> parametry generatora
      def destroy(what, *args)
        log :generate, what
        argument = args.map {|arg| arg.to_s }.flatten.join(" ")

        in_root { run_ruby_script("script/rails destroy #{what} #{argument}", :verbose => false) }
      end

      # Klasa generatora ORM
      #
      # * *Zwraca*:
      #   
      #   obiekt będący klasą generatora wybranego ORM
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

      # Instancja klasy generatora ORM
      #
      # * *Zwraca* :
      #   
      #   obiekt będący instancją klasy generatora wybranego ORM
      def orm_instance(name=singular_table_name)
        @orm_instance ||= @orm_class.new(name)
      end

      # Metoda pozwalająca uzyskać atrybuty elementów HTML ybranych pól
      #
      # * *Argumenty* :
      #   
      #   - +attr+ -> Atrybut klasy modelu
      #
      # * *Zwraca* :
      #   
      #   (+String+) rozpoczynającą się przecinkiem lista atrybutów elementu
      #   HTML pola
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

      # Metoda pozwalająca uzyskać typ pola z typu atrybutu klasy modelu
      #
      # * *Argumenty* :
      #   
      #   - +attr+ -> Atrybut klasy modelu
      #
      # * *Zwraca* :
      #
      #   (+Symbol+) typ pola
      def field_type(attr)
        if attr.type == :file
          :file_field
        elsif attr.type =~ /^tiny_mce_/
          :text_area
        else
          attr.field_type
        end
      end

      # Metoda pozwalająca uzyskać klasę lub listę klas CSS danego pola z typu
      # atrybutów modelu
      #
      # * *Argumenty* :
      #
      #   - +attr+ -> Atrybut klasy modelu
      #
      # * *Zwraca*:
      #   
      #   (+String+) połaczoną listę klas CSS elementu HTML
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

