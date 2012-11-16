module L
  # Moduł helpera dla lazy aplikacji.
  module LazyHelper

    # Generuj link w menu w panelu administracyjnym
    #
    # * *Argumenty*:
    #
    #   - +name+ - symbol nazwa moduły, małymi literami w liczbie mnogiej
    #   - +url+ - link do strony, automatycznie nenerowany jest przez
    #     metodę UrlHelper: +/name/_path+
    #   - +class_name+ - lista dodatkowych klas CSS
    #
    def admin_menu_link(name, url = nil, class_name = [])
      url = method("#{name}_path").call if url.nil?
      class_name = [*class_name]
      class_name.push('active') if controller_name == name.to_s
      link_to t("menu.#{name}"), url, class: class_name
    end

    # Metoda skracająca tekst (robiąca zajawkę). Na końcu dodawany jest wielokropek, jeżeli
    # orginalny tekst był dłuższy niż wymagana długość.
    #
    # * *Argumenty*:
    #
    #  - +value+ - tekst do skrócenia
    #  - +length+ - maksymalna długość teksty na wyjściu, domyślnie 50
    #
    def short(value, length=50)
      v = strip_tags(value)
      if v.mb_chars.length > length
        raw(v.mb_chars.slice(0,length-1).to_s + "&ellips;")
      else
        v
      end
    end

    # Metoda generująca 'okruszki' (ślad, ścieżkę) stron na której znajduje się
    # użytkownik.
    #
    # * *Argumenty*:
    #
    #   - +*value+ - link, lub tablica linków stron w kolejności od najdalszej
    #   do najbliższej użytkownikowi. Ostatnim elementem zwykle jest tytuł
    #   storny na której znajduje się użytkownik.
    def breadcrumbs(*value)
      bread = ['<a href="/">'+I18n.t('breadcrumbs.home')+'</a>']
      bread += value
      instantiate_yield :breadcrumbs, bread.join(' <span class="separator">&rsaquo;</span> ')
    end

    # Metoda generująca 'okruszki' (ślad, ścieżkę) stron na której znajduje się
    # użytkownik. Podobnie jak +breadcrumbs+ ale stroną główną jest główna
    # strona panelu administracyjnego
    #
    # * *Argumenty*:
    #
    #   - +*value+ - link, lub tablica linków stron w kolejności od najdalszej
    #   do najbliższej użytkownikowi. Ostatnim elementem zwykle jest tytuł
    #   storny na której znajduje się użytkownik.
    def breadcrumbs_admin(*value)
      bread = ['<a href="/admin">'+I18n.t('admins.show.title')+'</a>']
      bread += value
      instantiate_yield :breadcrumbs, bread.join(' <span class="separator">&rsaquo;</span> ')
    end


    # Metoda ustawiająca tytuł strony.
    #
    # * *Argumenty*:
    #
    #   - +value+ - tytuł strony
    def title(value)
      instantiate_yield :title, value
      content_for(:title) { value }
    end

    # Metoda ustawiająca słowa kluczowe strony.
    #
    # * *Argumenty*:
    #
    #   - +value+ - tytuł strony
    def keywords(value)
      instantiate_yield :keywords, value
    end

    # Metoda ustawiająca meta opis strony.
    #
    # * *Argumenty*:
    #
    #   - +value+ - tytuł strony
    def description(value)
      instantiate_yield :description, value
    end

    # Pobierz aktualną wartość 'okruszków'
    def yield_breadcrumbs
      raw @value_for_meta_breadcrumbs
    end

    # Pobierz aktualną wartość meta opisu strony.
    def yield_description
      @value_for_meta_description||t('meta.description')
    end

    # Pobierz aktualną wartość słów kluczowych strony.
    def yield_keywords
      @value_for_meta_keywords||t('meta.keywords')
    end

    # Pobierz aktualny tytuł strony.
    def yield_title
      @value_for_meta_title||t('meta.title')
    end

    private
    def instantiate_yield key, value
      value = t("meta.#{key}") if value.blank?
      if instance_variable_defined?("@value_for_meta_#{key}")
        v = instance_variable_get("@value_for_meta_#{key}")
        instance_variable_set("@value_for_meta_#{key}", v + value)
      else
        instance_variable_set("@value_for_meta_#{key}", value)
      end
    end
  end
end

