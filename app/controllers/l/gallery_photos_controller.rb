module L
  # Kontroler pozwalający dodawać i usuwać zdjęcia z galerii.
  #
  class GalleryPhotosController < ApplicationController
    #
    # Akcja usuwa wybrane zdjęcie z galerii.
    #
    # *DELETE* /galleries/1/gallery_photos/1
    #
    def destroy
      @photo = L::GalleryPhoto.find(params[:id])
      @gallery_photos = @photo.gallery.gallery_photos
      @delete = @photo.destroy
    end

    # Akcja dodaje nowe zdjęcie do galerii. Zdjęcie jest zapisywane na serwerze
    # o podawane wstępnej obróbce (zapisane w róznych rozmiarach).
    #
    # *POST* /galleries/1/gallery_photos
    #
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
