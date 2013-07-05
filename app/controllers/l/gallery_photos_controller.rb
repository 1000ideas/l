module L
  # Kontroler pozwalający dodawać i usuwać zdjęcia z galerii.
  #
  class GalleryPhotosController < ApplicationController
    #
    # Akcja usuwa wybrane zdjęcie z galerii.
    #
    # *DELETE* /galleries/1/photos/1
    #
    def destroy
      @photo = L::GalleryPhoto.find(params[:id])
      authorize! :destroy, @photo

      @gallery_photos = @photo.gallery.gallery_photos
      @delete = @photo.destroy

      respond_to do |format|
        format.js
      end
    end

    # Akcja dodaje nowe zdjęcie do galerii. Zdjęcie jest zapisywane na serwerze
    # o podawane wstępnej obróbce (zapisane w róznych rozmiarach).
    #
    # *POST* /galleries/1/photos
    #
    def create
      @photo = L::GalleryPhoto.new(swfupload_file: params[:Filedata],
                                   gallery_id: params[:gallery_id])
      authorize! :create, @photo

      @saved = @photo.save
      @gallery = @photo.gallery
      @gallery_photos = @gallery.gallery_photos

      respond_to do |format|
        format.js
      end
    end
  
  end
end
