module L
  class GalleryPhoto < ActiveRecord::Base
    attr_accessible :gallery_id, :photo, :swfupload_file

    belongs_to :gallery
    has_attached_file :photo, 
      :styles => { 
        :big => "800x600>",
        :medium => "300x300>", 
        :small_crop => "120x120", 
        :small => "120x120>", 
        :thumb => "100x100>",
        :mobile_thumb => "80x80#" },
      :path => ":rails_root/public/system/gallery_photos/:id/:style/:filename",
      :url => "/system/gallery_photos/:id/:style/:filename"


    # Fix the mime types. Make sure to require the mime-types gem
    def swfupload_file=(data)
      data.content_type = MIME::Types.type_for(data.original_filename).to_s
      self.photo = data
    end
  end

end
