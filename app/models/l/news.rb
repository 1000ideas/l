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
    include ::PublicActivity::Common
    acts_as_paranoid

    if (ActiveRecord::Base.connection.table_exists? 'news_drafts')
    has_draft do
      attr_accessible :title, :content, :photo, :published_at,
      :published_at_formatted, :photo_delete, :news_id, :translations_attributes

      if (ActiveRecord::Base.connection.table_exists? 'news_draft_translations')
        translates :title, :content
        accepts_nested_attributes_for :translations
      end
      
      has_attached_file :photo,
      styles: { thumb: "120x90", small: "200x200>", medium: "600x400>" },
      path: ":rails_root/public/system/news_photos_draft/:id/:style/:filename",
      url: "/system/news_photos_draft/:id/:style/:filename"
      #preserve_files: true
      validates :photo, attachment_content_type: { content_type: %r{^image/} }
      def published?
        published_at.present? and published_at < Time.now
      end
      
      def photo_delete # :nodoc:
        false
      end

      def photo_delete=(value) # :nodoc:
        self.photo.clear if value.to_i == 1
      end
    end
    end
    
    scope :ordered, order("`#{table_name}`.`created_at` DESC")
    scope :visible, where("`#{table_name}`.`published_at` < ?", Time.now)
    self.per_page = 10

    attr_accessible :title, :content, :photo, :published_at,
      :published_at_formatted, :photo_delete, :translations_attributes, :draft

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

    def published_at_formatted
      unless published_at.nil?
        I18n.l(self.published_at, format: :edit)
      end
    end

    def published_at_formatted= value
      self.published_at = value
    end

    def published?
      published_at.present? and published_at < Time.now
    end

    def publish!
      self.published_at ||= Time.now
    end

    def draft!
      self.published_at = nil if published?
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
