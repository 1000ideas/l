# coding: utf-8
module L
  # Kontroler modułu galerii.
  #
  # Pozwala administratorowi dodawać edytować i usuwać galerie i zdjęcia.
  # Niezalogowany użytkownik ma dostęp do akcji list i show.
  class GalleriesController < ApplicationController

    layout "l/layouts/admin"
  
    uses_tinymce :simple, :only => [:new, :edit, :create, :update]

    # Akcja wyświetlająca listę galerii w panelu administracyjnym.
    #
    # *GET* /galleries
    #
    def index
      @galleries = L::Gallery.paginate page: params[:page]
      authorize! :menage, L::Gallery

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

      render :layout => "l/layouts/standard"
    end

    # Akcja wyświetlająca formularz dodania nowej galerii w panelu
    # administracyjnym.
    #
    # *GET* /galleries/new
    #
    def new
      @gallery = L::Gallery.new
      authorize! :create, @gallery

      I18n.available_locales.each {|locale|
        @gallery.translations.build :locale => locale
      }

      respond_to do |format|
        format.html
      end
    end

    # Akcja wyświetlająca formularz edycji istniejącej galerii w panelu
    # administracyjnym.
    #
    # *GET* /galleries/1/edit
    #
    def edit
      @gallery = L::Gallery.find(params[:id])
      authorize! :update, @gallery

      @gallery_photos = @gallery.gallery_photos
    end

    # Akcja tworząca nową galerię. Dostęp tylko dla administratora.
    #
    # *POST* /galleries
    #
    def create
      @gallery = L::Gallery.new(params[:l_gallery])
      authorize! :create, @gallery

      respond_to do |format|
        if @gallery.save
          format.html { redirect_to(edit_gallery_path(@gallery), :notice => I18n.t('create.success')) }
        else
          format.html { render :action => "new" }
        end
      end
    end

    # Akcja aktualizująca istniejącą galerię. Dostęptylko dla zalogowanego
    # administratora.
    #
    # *PUT* /galleries/1
    #
    def update
      @gallery = L::Gallery.find(params[:id])
      authorize! :update, @gallery

      respond_to do |format|
        if @gallery.update_attributes(params[:l_gallery])
          format.html { redirect_to(galleries_path, :notice => I18n.t('update.success')) }
        else
          format.html { render :action => "edit" }
        end
      end
    end

    # Akcja wyświetlająca listę galeri, dostępna dla wszystkich.
    #
    # *GET* /galleries/list
    #
    def list
      @gallery = L::Gallery.paginate(page: params[:page], per_page: 5)
      authorize! :read, L::Gallery

      render :layout => "l/layouts/standard"
    end

    # Akcja usuwająca galerię wraz ze wszytkimi zdjęciami. Dostępna tylko dla
    # administratora.
    #
    # *DELETE* /galleries/1
    #
    def destroy
      @gallery = L::Gallery.find(params[:id])
      authorize! :destroy, @gallery

      @gallery.destroy
      
      respond_to do |format|
        format.html { redirect_to(galleries_path) }
      end
    end

  end
end
