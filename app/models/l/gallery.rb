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
    has_many :gallery_photos, :dependent => :destroy
    attr_accessible :name, :content, :translations_attributes

    validates :name, presence: true

    translates :name, :content
    accepts_nested_attributes_for :translations

    # Metoda pobierajaca link to miniatury galerii (do pierwszego dodanego
    # obrazka).
    #
    # * *Argumenty*:
    #
    #   - +style+ - styl miniatury, domyślnie +:thumb+
    #
    def thumbnail(style = :thumb)
      self.gallery_photos.first.photo.url(style)
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
