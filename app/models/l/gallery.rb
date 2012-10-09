module L
  class Gallery < ActiveRecord::Base
    has_many :gallery_photos, :dependent => :destroy
    attr_accessible :name, :content, :translations_attributes

    validates :name, presence: true

    translates :name, :content
    accepts_nested_attributes_for :translations

    def thumbnail(style = :thumb)
      self.gallery_photos.first.photo.url(:thumb)
    rescue
      ''
    end

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
