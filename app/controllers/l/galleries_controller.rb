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
      authorize! :menage, :all
      @galleries = L::Gallery.
        paginate :page => params[:page], :per_page => params[:per_page]||10

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @galleries }
      end
    end

    # Akcja wyświetlająca pojedynczą galerię. Dostępna dla wszystkich.
    #
    # *GET* /galleries/1
    #
    def show
      @gallery = L::Gallery.find(params[:id])

      render :layout => "l/layouts/standard"
    end

    # Akcja wyświetlająca formularz dodania nowej galerii w panelu
    # administracyjnym.
    #
    # *GET* /galleries/new
    #
    def new
      authorize! :menage, :all
      @gallery = L::Gallery.new
      (I18n.available_locales).each {|locale|
        @gallery.translations.build :locale => locale
      }
      @parents = L::Gallery.all

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @gallery }
      end
    end

    # Akcja wyświetlająca formularz edycji istniejącej galerii w panelu
    # administracyjnym.
    #
    # *GET* /galleries/1/edit
    #
    def edit
      authorize! :menage, :all
      @gallery = L::Gallery.find(params[:id])
      @gallery_photos = @gallery.gallery_photos

    end

    # Akcja tworząca nową galerię. Dostęp tylko dla administratora.
    #
    # *POST* /galleries
    #
    def create
      authorize! :menage, :all
      @gallery = L::Gallery.new(params[:l_gallery])

      respond_to do |format|
        if @gallery.save
          format.html { redirect_to(edit_gallery_path(@gallery), :notice => I18n.t('create.success')) }
          format.xml  { render :xml => @gallery, :status => :created, :location => @gallery }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @gallery.errors, :status => :unprocessable_entity }
        end
      end
    end

    # Akcja aktualizująca istniejącą galerię. Dostęptylko dla zalogowanego
    # administratora.
    #
    # *PUT* /galleries/1
    #
    def update
      authorize! :menage, :all
      @gallery = L::Gallery.find(params[:id])

      respond_to do |format|
        if @gallery.update_attributes(params[:l_gallery])
          format.html { redirect_to(galleries_path, :notice => I18n.t('update.success')) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @gallery.errors, :status => :unprocessable_entity }
        end
      end
    end

    # Akcja wyświetlająca listę galeri, dostępna dla wszystkich.
    #
    # *GET* /galleries/list
    #
    def list
      @gallery = L::Gallery.all.paginate :page => params[:page], :per_page => params[:per_page]||5
      render :layout => "l/layouts/standard"
    end

    # Akcja usuwająca galerię wraz ze wszytkimi zdjęciami. Dostępna tylko dla
    # administratora.
    #
    # *DELETE* /galleries/1
    #
    def destroy
      authorize! :menage, :all
      @gallery = L::Gallery.find(params[:id])
      @gallery.destroy

      respond_to do |format|
        format.html { redirect_to(galleries_path) }
        format.xml  { head :ok }
      end
    end

  end
end
