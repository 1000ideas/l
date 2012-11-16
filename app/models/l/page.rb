module L
  # Model reprezentujący stronę stałą.
  #
  # * *Atrybuty*:
  #
  #   - +title+ - Tytuł strony
  #   - +url+ - fragment url strony
  #   - +content+ - treść strony
  #   - +meta_description+ - metaopis strony
  #   - +meta_keywords+ - słowa kluczowe dla strony
  #   - +position+ - pozycja w danej gałęzi drzewa
  #   - +parent_id+ - ID strony nadrzędnej
  #   - +hidden_flag+ - flaga określająca czy strona jest ukryta
  #   
  # * *Relacje*:
  #
  #   - <tt>belongs_to :parent</tt> - (Page) strona nadrzędna
  #   - <tt>has_many :children</tt> - Strony podrzędne
  #
  # Tłumaczone atrybuty: +title+ i +content+.
  #
  class Page < ActiveRecord::Base
    validates :title, presence: true
    validates :url, presence: true
    validates :url, uniqueness: true

    attr_accessible :title, :url, :content, :meta_description, :meta_keywords,
      :position, :parent_id, :hidden_flag, :translations_attributes

    translates :title, :content
    accepts_nested_attributes_for :translations

    acts_as_tree order: "position"
  
    after_save :set_default_position

    # Strony podrzędne które nie są ukryte.
    def unhidden_children
      self.children.delete_if { |ch| ch.hidden_flag == 1 }
    end
    
    # Metoda wyszukująca stron pasujący do podane frazy. Wyszukiwanie odbywa
    # się wg. atrybutów +title+ i +content+. Przy wyszukiwaniu uwzglądniany
    # jest aktualnie wybrany język. Mozna również określić czy wyszukiwać
    # strony ukryte czy widoczne.
    #
    # * *Argument*:
    #
    #   - +search+ - szukana fraza
    #   - +hidden+ - wartość +hidden_flag+ która nie ma być wyszukiwana, np:
    #     dla 1 wyszukujemy wszystkich widocznych stron.
    #     
    def self.search(search, hidden = 1)
      find :all,
        joins: :translations,
        conditions:
        ['(page_translations.title LIKE :pattern OR page_translations.content LIKE :pattern) AND locale = :locale AND hidden_flag <> :flag',
        {
          pattern: "%#{search}%",
          locale: I18n.locale,
          flag: hidden
        }
      ]
    end

    # Sprawdz czy podana strona jest przodkiem.
    #
    # * *Argumenty*:
    #
    #   - +page+ - strona która może być przodkiem.
    def ancestor?(page)
      not ancestors.find {|p| p.id == page.id}.nil?
    end


    # Wstawia stroną w stukturę stron na pozycji za podaną stroną. Strony muszą
    # mieć tego samego rodzica.
    #
    # * *Argumenty*:
    #
    #   - +where_page+ - strona za którą należy wstawić wybraną stronę.
    #
    def drop_after(where_page)
      return false if where_page.parent_id != parent_id
      if position > where_page.position
        n_pos = where_page.position + 1
        L::Page.where(['position >= ? and position < ?', n_pos, position]).each do |p|
          p.update_attribute :position, p.position + 1
        end
        update_attribute :position, n_pos
      else
        n_pos = where_page.position
        L::Page.where(['position > ? and position <= ?', position, n_pos]).each do |p|
          p.update_attribute :position, p.position - 1
        end
        update_attribute :position, n_pos
      end
    end

    # Wypina stronę z drzewa stron i wpina ją pod podanym rodzicem. Nowa strona
    # rodzic nie może należeć do potomków wybranej strony.
    #
    # * *Argumenty*:
    #
    #   - +p+ - strona która ma się stać nowym rodzicem wybranej strony.
    #
    def change_parent(p)
      pid = p ? p.id : nil
      fc = p.children.order('position').first unless p.nil?
      fcp = fc ? fc.position : 1
      update_attributes position: (fcp - 1), parent_id: pid
    end

    # Wstawia stronę obok wybranej strony nie zależnie od tego czy mają
    # wspólnego rodzica.
    #
    # * *Argumenty*:
    #
    #   - +where_page+ - strona za którą nalezy wstawić wybraną stronę.
    #
    def set_sibling_and_drop_after(where_page)
      change_parent(where_page.parent)
      drop_after(where_page)
    end

    # Pobiera token strony, czyli bezpośrednią ścieżkę url wybranej strony i stron
    # nadrzędnych.
    # 
    def get_token
      (ancestors.reverse.map { |p| p.url } + [url]).join('/')
    end

    # Wyszukuje strony przy pomocy tokena. Sprawdzana jest cała scieżka do
    # strony.
    #
    # * *Argumenty*:
    #
    #   - +token+ - ścieżka dostepu do strony, urle poszczególnych stron w
    #     drzewie oddzielone '/'.
    #
    def self.find_by_token(token)
      parent_id = nil
      page = nil
      tokens = token.split('/')
      tokens.each do |t|
        page = self.find_by_url_and_parent_id(t, parent_id)
        if t != tokens.last
          return nil if page.nil?
          parent_id = page.id
        end
      end
      page
    end

    private
    def set_default_position
      if position.nil?
        update_attribute :position, id
      end
    end

  end
end
