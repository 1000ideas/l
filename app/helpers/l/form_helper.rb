module L
  # Moduł helpera dodający metody ułatwiajace wstawianie pól formularza.
  module FormHelper

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
        name: 'sort',
        title:I18n.t("sort.#{type.to_s}"),
        value: "#{name.to_s}_#{type.to_s}"
      })

      options[:class] = ["sort", options.delete(:class)].compact.flatten

      if options[:class].is_a? String
        options[:class] = [options[:class], (type == :asc ? 'up' : 'down')].uniq
      elsif options[:class].is_a? Enumerable
        options[:class].push(type == :asc ? 'up' : 'down').uniq!
      end

      button_tag "", options
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

