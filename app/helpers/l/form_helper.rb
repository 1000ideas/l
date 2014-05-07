module L
  # Moduł helpera dodający metody ułatwiajace wstawianie pól formularza.
  module FormHelper

    def custom_check_box(object_name, method, options = {}, cvalue = '1', ucvalue = '0')
      class_name = *options.delete(:class)
      class_name.push :'custom-check-box'
      label(object_name, method, class: class_name) do
        [
          check_box(object_name, method, options, cvalue, ucvalue),
          content_tag(:i)
        ].join.html_safe
      end
    end

    module FormBuilder
      def select_box(method, object, options = {})
        plural_name = method.to_s.pluralize
        options.merge!(multiple: true)
        class_name = *options.delete(:class)
        class_name.push :'custom-check-box'
        tag_value = object.send(method).to_s.gsub(/\s/, "_").gsub(/[^-\w]/, "").downcase
        label("#{plural_name}_#{tag_value}", class: class_name) do
          [
            check_box(plural_name, options, object.send(method), nil),
            @template.content_tag(:i)
          ].join.html_safe
        end
      end
    end



    # Metoda wyswietlająca checkbox dla obiektu jakiego modelu. Uzywane przy
    # wybieraniu stron do masowych akcji na liście elementów.
    #
    # * *Argumenty*:
    #
    #   - +object+ - Obiekt dla którego chcemy wyświetlić checkbox (musi mieć
    #     +id+)
    #   - +name+ - nazwa grupy checkboksów, domyślnie +selected+. Używane w js
    #     do manipulacji wybranymi obiektami.
    #   - +options+ - opcje elementu checkbox, domyślnie: <tt>class='selection'</tt>
    #     i <tt>id="/name/_/id/</tt>.
    def selection_tag(object, name = 'selected', options = {})
      options.merge! class: 'selection', id: "#{name}_#{object.id}"
      check_box_tag "#{name}[]", object.id, false, options
    end

    def sort_column(name, *args)
      options = args.extract_options!
      title = args.pop || t(name, scope:[:sort_columns], default: name.to_s.titleize)
      direction = :asc

      disabled = options.delete(:disabled) { false }
      class_name = [:sort, *options.delete(:class)].compact

      if params[:sort].try(:[], :column).try(:to_sym) == name
        direction = params[:sort].try(:[], :dir) == 'asc' ? :desc : :asc
        class_name << :current
        class_name << direction
      end

      options[:class] = class_name

      filter = params[:filter]

      if disabled
        content_tag(:span, title, options)
      else
        link_to title, {sort: {column: name, dir: direction}, filter: filter}, options
      end
    end

    # Metoda wyświetlajaca przycisk do sortowania, jako +button_tag+.
    #
    # * *Argumenty*:
    #
    #   - +name+ - nazwa pola które chcemy sortować
    #   - +type+ - typ sortowania, +:desc+ lub +:asc+
    #   - +options+ - opcje elementu +submit_tag+, domyślnie klasa up/down w
    #     zależności od typu sortowania, <tt>name="sort"</tt> oraz tytuł
    #     (+title+) równie tłumaczeniu +sort.asc+ lub +sort.desc+, do zmiany w
    #     pliku +config/locales/pl.yml+.
    def sort_tag(name, type, options = {})
      options = options.reverse_merge({
        title: I18n.t("sort.#{type.to_s}")
      })

      class_name = ["sort", *options.delete(:class)]

      sort_type = "#{name.to_s}_#{type.to_s}"

      if (params[:sort] == sort_type)
        class_name << "current"
      end

      class_name << (type == :asc ? 'up' : 'down')

      options[:class] = class_name

      link_to "", {sort: sort_type}, options
    end

    # Tag input[type=files] obsługiwany przez plugin
    # jquery-fileupload. Argumenty jak w file_field_tag.
    # Domyślnie możliwy wybór wielu plików
    #
    def file_upload_tag(name, options = {})
      class_name = options.delete(:class)
      options[:class] = [:fileupload, :'custom-file-input', class_name].flatten.compact!
      options[:multiple] = true if options[:multiple].nil?

      options[:data] ||= {}
      options[:data][:label] ||= I18n.t(:label, default: 'Select file', scope: 'helpers.fileupload')

      file_field_tag(name, options)
    end
  end
end

