# coding: utf-8
module L::Admin
  # Kontroler modułu galerii.
  #
  # Pozwala administratorowi dodawać edytować i usuwać galerie i zdjęcia.
  class GalleriesController < AdminController

    # Akcja wyświetlająca listę galerii w panelu administracyjnym.
    #
    # *GET* /galleries
    #
    def index
      authorize! :manage, L::Gallery

      @galleries = L::Gallery
        .with_translations
        .filter(params[:filter])
      @galleries = @galleries.order(sort_order(:galleries)) if sort_results?
      @galleries = @galleries.paginate(page: params[:page])

      respond_to do |format|
        format.html
        format.js
      end
    end

    # Akcja wyświetlająca formularz dodania nowej galerii w panelu
    # administracyjnym.
    #
    # *GET* /galleries/new
    #
    def new
      @gallery = L::Gallery.new
      authorize! :create, @gallery

      respond_to do |format|
        format.html
        format.js
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

      respond_to do |format|
        format.html
        format.js
      end
    end
    # Akcja wyświetlająca formularz edycji szkicu. Dostępne tylko
    # dla administratora.
    #
    # *GET* /galleries/1/edit_draft
    #
    def edit_draft
      @gallery = L::Gallery.find(params[:id]).draft
      authorize! :update, @gallery
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
          @gallery.create_activity :create, owner: current_user
          flash.notice = info('success')
          format.html { redirect_to(edit_admin_gallery_path(@gallery)) }
          format.js
        else
          format.html { render :action => "new" }
          format.js
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
        if params.has_key?(:save_and_publish)
          if @gallery.update_attributes(params[:l_gallery])
            @gallery.create_activity :update, owner: current_user
            flash.notice = info('success')
            format.html { redirect_to(admin_galleries_path) }
            format.js
          else
            format.html { render :action => "edit" }
            format.js
          end
        elsif params.has_key?(:create_draft)
          if @gallery.instantiate_draft!
            flash.notice = info(:success_drafte)
            format.html { render action: "edit" }
            format.js
          else
            format.html { render action: "edit" }
            format.js
          end
        end    
      end
    end

    # Akcja aktualizująca istniejący szkic. Dostępne tylko dla administratora.
    #
    # *put* /pages/1
    #
    def update_draft
      @gallery = L::Gallery::Draft.find(params[:id])
      
      respond_to do |format|
      if params.has_key?(:save_draft)
        if @gallery.update_attributes(params[:l_gallery_draft])
          flash.notice = info(:success)
          format.html
        else
          format.html { render action: "edit_draft" }
         end
         format.js
      elsif params.has_key?(:delete_draft)
            @gallery = @gallery.gallery
            @gallery.destroy_draft! 
            format.html {redirect_to edit_admin_gallery_path(@gallery), notice: info(:success) }
      elsif params.has_key?(:publish_draft)
          @gallery = @gallery.gallery
          
          if @gallery.replace_with_draft!
            @gallery.destroy_draft!
            format.html {redirect_to edit_admin_gallery_path(@gallery), notice: info(:success) }
          else
              format.html { render action: "edit_draft" }
              format.js
          end
      end
      end 
          
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
      @gallery.create_activity :destroy, owner: current_user

      respond_to do |format|
        format.html { redirect_to(admin_galleries_path) }
      end
    end

    # Akcja pozwalająca wykonać masowe operacje na zaznaczonych elementach.
    # Wymagane parametry to selection[ids] oraz selection[action].
    #
    # *POST* /admin/galleries/selection
    #
    def selection
      authorize! :manage, L::Gallery
      selection = {
        action: params[:bulk_action],
        ids: params[:ids]
      }
      selection = L::Gallery.selection_object(selection)

      respond_to do |format|
        if selection.perform!
          selection.each do |obj|
            obj.create_activity selection.action, owner: current_user
          end
          format.html { redirect_to :back, notice: info(selection.action, :success) }
        else
          format.html { redirect_to :back, alert: info(selection.action, :failure) }
        end
      end
    end

  end
end
