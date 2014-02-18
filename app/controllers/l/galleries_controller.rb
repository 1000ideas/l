# coding: utf-8
module L
  # Kontroler modułu galerii.
  #
  # Pozwala administratorowi dodawać edytować i usuwać galerie i zdjęcia.
  # Niezalogowany użytkownik ma dostęp do akcji list i show.
  class GalleriesController < ApplicationController

    layout "l/standard"

    # Akcja wyświetlająca listę galerii. Dostepna dla wszystkich.
    #
    # *GET* /galleries
    #
    def index
      authorize! :read, L::Gallery
      @galleries = L::Gallery
        .ordered
        .paginate page: params[:page]

      respond_to do |format|
        format.html
      end
    end

    # Akcja wyświetlająca pojedynczą galerię. Dostępna dla wszystkich.
    #
    # *GET* /galleries/1
    #
    def show
      @gallery = L::Gallery.find(params[:id])
      authorize! :read, @gallery

      respond_to do |format|
        format.html
      end
    end

  end
end
