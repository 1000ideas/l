module L
  #
  # Model reprezentujący gelerię.
  #
  # * *Atrybuty*:
  #
  #   - +name+ - nazwa galerii,
  #   - +content+ - opis galerii.
  #
  # * *Relacje*:
  #
  #   - <tt>has_namy :gallery_photos</tt> - (GalleryPhoto) zdjęcia dodane do galerii.
  #
  # Tłumaczone atrybuty: +name+, +content+.
  #
  class Gallery < ActiveRecord::Base
    include ::PublicActivity::Common
    acts_as_paranoid

    scope :ordered, order("`#{table_name}`.`created_at` DESC")
    self.per_page = 10

    has_many :gallery_photos, :dependent => :destroy
    attr_accessible :name, :content, :translations_attributes
    
    has_draft do
      attr_accessible :name, :content, :gallery_id, :translations_attributes
      translates :name, :content
      accepts_nested_attributes_for :translations

      def self.search(search)
      find :all,
        :joins => :translations,
        :conditions =>
        ['(gallery_draft_translations.name LIKE :pattern OR gallery_draft_translations.content LIKE :pattern) AND locale = :locale',
        {
          :pattern => "%#{search}%",
          :locale => I18n.locale
        }
      ]
    end
    end

    validates :name, presence: true

    translates :name, :content
    translation_class.acts_as_paranoid
    accepts_nested_attributes_for :translations

    scope :filter_by_name, lambda{|name| where("`#{translations_table_name}`.`name` LIKE ?", "%#{name}%")}
    scope :filter_by_updated_before, lambda{|date| where("`#{table_name}`.`updated_at` < ?", Date.parse(date))}
    scope :filter_by_updated_after, lambda{|date| where("`#{table_name}`.`updated_at` > ?", Date.parse(date))}

    # Metoda pobierajaca link to miniatury galerii (do pierwszego dodanego
    # obrazka).
    #
    # * *Argumenty*:
    #
    #   - +style+ - styl miniatury, domyślnie +:thumb+
    #
    def thumbnail(style = :thumb)
      self.gallery_photos.first.try(:photo, style)
    rescue
      ''
    end

    # Metoda klasy pozwalająca szukać stron pasujacych do zadanej frazy. Strony
    # są wyszukiwane po tytule i treście wg. aktualnie wybranego języka.
    #
    # * *Argumenty*:
    #
    #   - +search+ - szukna fraza
    #
    def self.search(search)
      find :all,
        :joins => :translations,
        :conditions =>
        ['(galleries_translations.name LIKE :pattern OR galleries_translations.content LIKE :pattern) AND locale = :locale',
        {
          :pattern => "%#{search}%",
          :locale => I18n.locale
        }
      ]
    end


  end
end
