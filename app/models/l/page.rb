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
    validate :unique_url_within_siblings

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

    # Wstawia stronę jako ostatnie dziecko strony +page+. Zapewnie spójność
    # danych. Sprawdza czy strony nie będą tworzyły pętli oraz wszystkie
    # walidatory strony (szczególnie niepowtarzalność +url+ w obrębie rodzica). W
    # przypadku błędu wyrzucany jest wyjątek
    # <tt>ActiveRecord::RecordInvalid</tt>.
    #
    # * *Argumenty*:
    #
    #   - +page+ - strona która ma zostać nowym rodzicem strony.
    #
    def set_parent!(page)
      Page.transaction do
        unless self.change_parent(page)
          raise ActiveRecord::RecordInvalid.new(self)
        end
      end
      true
    end

    # Wstawia stronę jako następną w kolejności za stronę +page+. W razie
    # potrzeby zmieniany jest rodzic strony. Zapewnia spójność danych. Sprawdza
    # czy strony nie tworzą pętli oraz przeprowadza walidację (w szczególnosci
    # niepowtarzalność +url+ w obrębie rodzica). W przypadku błędu wyrzucany
    # jest wyjątek <tt>ActiveRecord::RecordInvalid</tt>
    #
    # * *Argumenty*:
    #
    #   - +page+ - strona która ma poprzedzać wybraną stronę.
    #
    def insert_after!(page)
      Page.transaction do
        if parent_id != page.parent_id
          unless self.change_parent(page.parent)
            raise ActiveRecord::RecordInvalid.new(self)
          end
        else
          self.class.where('position > ?', position).where(parent_id: parent_id).
            update_all('position = position-1')
          page.reload
        end  
        unless self.drop_after(page)
          raise ActiveRecord::RecordInvalid.new(self)
        end
      end
      true
    end

    # Wstawia stroną w stukturę stron na pozycji za podaną stroną. Strony muszą
    # mieć tego samego rodzica.
    #
    # * *Argumenty*:
    #
    #   - +where_page+ - strona za którą należy wstawić wybraną stronę.
    #
    def drop_after(where_page)
      if parent_id != where_page.parent_id
        errors.add(:parent_id, :diffrent)
        return false
      end
      new_position = where_page.position + 1
      unless new_position == position
        self.class.where('position >= ?', new_position).
          where(parent_id: parent_id).
          update_all('position = position+1')
        update_attribute :position, new_position
      else
        true
      end
    end

    # Wypina stronę z drzewa stron i wpina ją pod podanym rodzicem. Nowa strona
    # rodzic nie może należeć do potomków wybranej strony. Strona dodawana jest
    # na koniec listy dzieci.
    #
    # * *Argumenty*:
    #
    #   - +new_parent+ - strona która ma się stać nowym rodzicem wybranej strony.
    #
    def change_parent(new_parent = nil)
      if new_parent and ( new_parent.ancestor?(self) or new_parent.id == id)
        errors.add(:parent_id, :loop)
        return false
      end
      pid = new_parent ? new_parent.id : nil
      old_parent_id = parent_id
      old_position = position
      position = nil
      status = update_attributes(position: nil, parent_id: pid)
      self.class.where('position > ?', old_position).where(parent_id: old_parent_id).
        update_all('position = position-1')
      status
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
    
    # Sprawdza czy pośród rodzeństwa nie ma stron o takim samym url
    def unique_url_within_siblings
      errors.add(:url, :taken) if siblings.count {|p| p.url == url } > 0
    end


    def set_default_position
      if position.nil?
        new_position = self.class.where(parent_id: parent_id).all.count {|p| (not p.position.nil?) and p.id != id }
        update_column(:position, new_position)
      end
    end

  end
end
