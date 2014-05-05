module L
  # Moduł helpera pomoagającego w filtrowaniu i sortowaniu elementów w panelu
  module FilterHelper

    # Metoda pobierająca wartość filtra o danym id
    #
    # * *Argumenty* :
    #
    #   - +name+ - id filtrowanego pola
    #
    # * *Zwraca* :
    #
    #   - wartość filtra lub +nil+ w przypadku gdy dany filtr nie istnieje/dane
    #     nie są filtrowane po tym polu
    #
    def filter(name)
      params[:filter][name] unless params[:filter].blank?
    end

    # Metoda pobierająca porządek sortowania
    #
    # * *Argumenty*:
    #
    #   - +table_name+ - Nazwa tabeli, jeśli chcemy sortować po polu z tabeli
    #     złączonej
    #
    # * *Zwraca*:
    #
    #   - nazwę pola (lub nazwę pola poprzedzoną nazwą tabeli) i porządek
    #     sortowania (DESC/ASC) przekazany przez parametry, lub pusty +String+
    #     w przypadku gdy nie wybrano sortowania
    #
    def sort_order(table_name = nil)
      return '' if params[:sort].blank?
      name = params[:sort][:column]
      type = params[:sort][:dir]
      table_name.blank? ? "`#{name}` #{type}" : "`#{table_name}`.`#{name}` #{type}"
    end

    # Metoda sprawdza czy należy sortować wyniki
    #
    # * *Zwraca*:
    #
    #   - (+Boolean+) prawda lub fałsz w zależności czy przekazano
    #     parametr +:sort+
    def sort_results?
      ! params[:sort].blank?
    end

  end
end
