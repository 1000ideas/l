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
    validates :url, presence: true, uniqueness: {scope: :parent_id}
    validate :detect_tree_loops

    attr_accessible :title, :url, :content, :meta_description, :meta_keywords,
      :position, :parent_id, :hidden_flag, :translations_attributes

    translates :title, :content
    accepts_nested_attributes_for :translations

    acts_as_tree
  
    after_save :set_default_position

    sortable :position, scope: :parent_id

    # Strony podrzędne które nie są ukryte.
    def unhidden_children
      self.children.where(hidden_flag: false)
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

    # Pobiera token strony, czyli bezpośrednią ścieżkę url wybranej strony i stron
    # nadrzędnych.
    # 
    def get_token
      (ancestors.reverse.map { |p| p.url } + [url]).join('/')
    end

    # Wyszukuje strony przy pomocy tokena. Sprawdzana jest cała scieżka do
    # strony. Gdy strona nie zostanie znaleziona zostaje wyrzucony wyjątek
    # <tt>ActiveRecord::RecordNotFound</tt>.
    #
    # * *Argumenty*:
    #
    #   - +token+ - ścieżka dostepu do strony, urle poszczególnych stron w
    #     drzewie oddzielone '/'.
    #
    def self.find_by_token(token)
      parent_id = nil
      _page = nil
      token.split('/').each do |url|
        _page = self.where(url: url, parent_id: parent_id).first!
        parent_id = _page.id
      end
      _page
    end

    private
    
    # # Sprawdza czy pośród rodzeństwa nie ma stron o takim samym url
    # def unique_url_within_siblings
    #   errors.add(:url, :taken) if siblings.count {|p| p.url == url } > 0
    # end

    # Sprawdza czy istnieją zapętlenia w drzewie stron
    def detect_tree_loops
      page = self
      until page.parent.nil?
        if page.parent_id == self.id
          errors.add(:parent_id, :loop)
          break
        end
        page = page.parent
      end
    end


    def set_default_position
      if position.nil?
        new_position = self.class.where(parent_id: parent_id).all.count {|p| (not p.position.nil?) and p.id != id }
        update_column(:position, new_position)
      end
    end

  end
end
