module L
  class News < ActiveRecord::Base
    attr_accessible :title, :content, :photo, :photo_delete, :translations_attributes

    has_attached_file :photo, 
      :styles => { :thumb=> "120x90", :small => "200x200>", :medium  => "600x400>" },
      :path => ":rails_root/public/system/news_photos/:id/:style/:filename",
      :url => "/system/news_photos/:id/:style/:filename"


    validates :title, :presence => true
    validates :content, :presence => true
    validates_attachment_content_type :photo,
      :content_type => ['image/jpeg', 'image/png', 'image/gif', 'image/bmp']
  
    @@per_page = 5

    translates :title, :content
    accepts_nested_attributes_for :translations

    
    def photo_delete
      false
    end

    def photo_delete=(value)
      self.photo.clear if value.to_i == 1
    end

    def see_more(count = 5)
      self.class.where([ "`id` != ?", id ]).order("created_at DESC").limit(count)
    end

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
