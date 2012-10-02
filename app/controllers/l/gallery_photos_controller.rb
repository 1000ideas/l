module L
  class GalleryPhotosController < ApplicationController
    # DELETE /galleries/1
    # DELETE /galleries/1.xml
    def destroy
      @photo = L::GalleryPhoto.find(params[:id])
      @gallery_photos = @photo.gallery.gallery_photos
      @delete = @photo.destroy
    end

    def create
      # SWFUpload file
      @photo = L::GalleryPhoto.new(swfupload_file: params[:Filedata],
                                   gallery_id: params[:gallery_id])
      @saved = @photo.save
      @gallery = L::Gallery.find(params[:gallery_id])
      @gallery_photos = @gallery.gallery_photos
    end
  
  end
end
