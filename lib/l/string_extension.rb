module L
  # Moduł rozszerzenia dla klasu +String+
  module StringExtension

    # Metoda zamienia string na taki dający się włozyć do URL
    #
    # * *Argumenty*:
    #
    #   - +space+ - znak który ma być wstawiany w miejscu spacji, domyślnie '-'
    #
    # * *Zwraca* :
    #
    #   (+String+) ciąg znaków zawierający tylko małe litery cyfry i odstępy
    #   zależne od argumenty +space+
    def urlize(space = '-')
      ActiveSupport::Inflector.transliterate(self).downcase.gsub(%r{[^a-z0-9]+}, space)
    end
  end
end

