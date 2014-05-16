module L
  # Model reprezentujący wiadomość należącą do aktualności.
  #
  # * *Atrybuty*:
  #
  #   - +title+ - tytuł wiadomości,
  #   - +content+ - treść wiadomości,
  #   - +photo+ - zdjęcie dla wiadomości, załącznik Paperclip,
  #   - +photo_delete+ - czy usunąć zdjęcie wiadomości.
  #
  # Tłumaczone atrybuty: +title+ i +content+.
  #
  class News < ActiveRecord::Base
    acts_as_paranoid

    scope :ordered, order("`#{table_name}`.`created_at` DESC")
    self.per_page = 10

    attr_accessible :title, :content, :photo, :published_at,
      :published_at_date, :photo_delete, :translations_attributes

    has_attached_file :photo,
      styles: { thumb: "120x90", small: "200x200>", medium: "600x400>" },
      path: ":rails_root/public/system/news_photos/:id/:style/:filename",
      url: "/system/news_photos/:id/:style/:filename",
      preserve_files: true

    validates :title, presence: true
    validates :content, presence: true
    validates :photo, attachment_content_type: { content_type: %r{^image/} }

    @@per_page = 5

    translates :title, :content
    translation_class.acts_as_paranoid

    accepts_nested_attributes_for :translations

    scope :filter_by_title, lambda{|title| where("`#{translations_table_name}`.`title` LIKE ?", "%#{title}%")}
    scope :filter_by_published_before, lambda{|date| where("`#{table_name}`.`published_at` < ?", Date.parse(date))}
    scope :filter_by_published_after, lambda{|date| where("`#{table_name}`.`published_at` > ?", Date.parse(date))}

    def photo_delete # :nodoc:
      false
    end

    def photo_delete=(value) # :nodoc:
      self.photo.clear if value.to_i == 1
    end

    def published_at
      super || created_at
    end

    def published_at_date
      unless published_at.nil?
        I18n.l( published_at.to_date, format: :edit)
      end
    end

    def published_at_date= value
      self.published_at = value
    end


    # Metoda pobierająca n pierwszych newsów innych od tej wiadomości.
    #
    # * *Argumenty*:
    #
    #   - +count+ - ilość pobieranych newsów, domyślnie 5.
    #
    def see_more(count = 5)
      self.class.where([ "`id` != ?", id ]).order("created_at DESC").limit(count)
    end

    # Metoda klasy pozwalająca wyszukiwać wiadomości pasujących do zadanej
    # frazy. Wyszukiwanie odbywa się po polach +title+ i +content+ i jest
    # zależne od aktualnie wybranego języka.
    #
    # * *Argumenty*:
    #
    #   - +search+ - szukana fraza.
    #
    def self.search(search)
      find :all,
        :joins => :translations,
        :conditions =>
        ['(news_translations.title LIKE :pattern OR news_translations.content LIKE :pattern) AND locale = :locale',
        {
          :pattern => "%#{search}%",
          :locale => I18n.locale
        }
      ]
    end

  end
end
