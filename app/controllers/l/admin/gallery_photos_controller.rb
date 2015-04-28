module L::Admin
  # Kontroler pozwalający dodawać i usuwać zdjęcia z galerii.
  #
  class GalleryPhotosController < AdminController
    #
    # Akcja usuwa wybrane zdjęcie z galerii.
    #
    # *DELETE* /galleries/1/photos/1
    #
    def destroy
      @gallery = L::Gallery.find(params[:gallery_id])
      @photo = @gallery.gallery_photos.find(params[:id])
      authorize! :destroy, @photo

      @photo.destroy
      @photo.create_activity :destroy, owner: current_user, recipient: @gallery

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
        @gallery = L::Gallery.find(params[:gallery_id])    
      
      if params.has_key?(:upload_gallery_photo)
        @photo = @gallery.gallery_photos.new(photo: params[:upload_gallery_photo])
      else
        @photo = @gallery.gallery_photos.new(params[:gallery_photo])
      end
      authorize! :create, @photo

      if @photo.save
        @photo.create_activity :create, owner: current_user, recipient: @gallery
      end

      respond_to do |format|
        format.js
      end
    end

  end
end
