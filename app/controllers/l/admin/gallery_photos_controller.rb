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
      @photo = @gallery.gallery_photos.new(photo: params[:photo])
      authorize! :create, @photo

      @photo.save

      respond_to do |format|
        format.js
      end
    end
  
  end
end
