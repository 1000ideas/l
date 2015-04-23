# encoding: utf-8
module L::Admin
  # Kotroler modułu stron stałych.
  #
  # Pozwala na dodawanie, edycje i usuwanie stron stałych. Używkonicy mogą
  # wyświetlać tylko pojedyncze strony.
  #
  class PagesController < AdminController

    # Akcja wyświetlająca listę istniejących stron w strukturze drzewiastej.
    #
    # *GET* /pages
    #
    def index
      authorize! :manage, L::Page


      @pages = L::Page
        .with_translations

      @pages = if filtering?
        @pages = @pages.order(sort_order(:pages)) if sort_results?
        @pages
          .filter(params[:filter])
          .paginate(page: params[:page])
      else
        @pages.ordered.roots
      end

      respond_to do |format|
        format.html
        format.js
      end
    end

    # Akcja wyświetlająca formularz tworzenia nowej strony. Dostep tylko dla
    # administratora.
    #
    # *GET* /pages/new
    #
    def new
      @page = L::Page.new
      authorize! :create, @page

      @parents = L::Page.all

      respond_to do |format|
        format.html
        format.js
      end
    end

    # Akcja wyświetlająca formularz edycji istniejącej strony. Dostępne tylko
    # dla administratora.
    #
    # *GET* /pages/1/edit
    #
    def edit
      @page = L::Page.find(params[:id])
      authorize! :update, @page
      logger.debug @page.inspect
      
      @parents = L::Page.where('`id` <> ?', @page.id).all
    end
    
    # Akcja wyświetlająca formularz edycji szkicu. Dostępne tylko
    # dla administratora.
    #
    # *GET* /pages/1/edit_draft
    #
    def edit_draft
      @page = L::Page.find(params[:id]).draft
      authorize! :update, @page

      @parents = L::Page.where('`id` <> ?', @page.page.id).all

    end

    # Akcja tworząca nową stronę. Dostęp tylko dla administratora.
    #
    # *POST* /pages
    #
    def create
      @page = L::Page.new(params[:l_page])
      authorize! :create, @page

      @parents = L::Page.all


      respond_to do |format|
        if @page.save
          @page.create_activity :create, owner: current_user
          flash.notice = info(:success)
          format.html { redirect_to( admin_pages_path ) }
          format.js
        else
          format.html { render action: "new" }
          format.js
        end
      end
    end

    # Akcja aktualizująca istniejącą stronę. Dostępne tylko dla administratora.
    #
    # *PUT* /pages/1
    #
    def update
      @page = L::Page.find(params[:id])
      authorize! :update, @page

      @parents = L::Page.all
      
      respond_to do |format|
        if params.has_key?(:save_and_publish)
          @page.publish! 
        
          if @page.update_attributes(params[:l_page])
            @page.create_activity :update, owner: current_user
            flash.notice = info(:success)
            format.html { redirect_to(admin_pages_path) }
            format.js
          else
            format.html { render action: "edit" }
            format.js
          end
        elsif params.has_key?(:commit)
          if @page.update_attributes(params[:l_page])
            @page.create_activity :update, owner: current_user
            flash.notice = info(:success)
            format.html { redirect_to(admin_pages_path) }
            format.js
          else
            format.html { render action: "edit" }
            format.js
          end
        elsif params.has_key?(:status)
          status = params[:status].to_i || 1
          name = ['unhide', 'hide'][status]

          if @page.update_attribute(:hidden_flag, status)
            @page.create_activity name, owner: current_user
            flash.notice = info(:success_hide)
            format.html { render action: "edit" }
            format.js
          else
            
            format.html { render action: "edit" }
            format.js
          end
        elsif params.has_key?(:create_draft)
          if @page.instantiate_draft!
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
      @page = L::Page::Draft.find(params[:id])
      
      respond_to do |format|
      if params.has_key?(:save_draft)
        if @page.update_attributes(params[:l_page_draft])
          flash.notice = info(:success)
          format.html 
          format.js
        else
          format.html { render action: "edit_draft" }
          format.js
         end
      elsif params.has_key?(:delete_draft)
            @page = @page.page
            @page.destroy_draft! 
            format.html {redirect_to edit_admin_page_path(@page), notice: info(:success) }
            
      elsif params.has_key?(:publish_draft)
          @page = @page.page
          
          if @page.replace_with_draft!
            @page.destroy_draft!
            format.html {redirect_to edit_admin_page_path(@page), notice: info(:success) }
          else
              logger.debug @page.errors.inspect
              format.html { render action: "edit_draft" }
              format.js
          end
      end
      end 
          
    end
    # Akcja usuwająca stronę. Dostępna tylko dla administratora.
    #
    # *DELETE* /pages/1
    #
    def destroy
      @page = L::Page.find(params[:id])
      authorize! :destroy, @page

      @page.destroy
      @page.create_activity :destroy, owner: current_user

      respond_to do |format|
        format.html { redirect_to :back, notice: info(:success) }
      end
    end

    # Akcja ukrywająca/pokazująca stronę. Dostępna tylko dla administratora
    #
    # *GET* /pages/1/hide
    #
    # *GET* /pages/1/unhide
    #
    def hide
      @page = L::Page.find(params[:id])
      authorize! :update, @page

      status = params[:status].to_i || 1
      name = ['unhide', 'hide'][status]



      if @page.update_attribute(:hidden_flag, status)
        @page.create_activity name, owner: current_user
        redirect_to :back, notice: info(name, :success)
      else
        redirect_to :back, notice: info(name, :failure)
      end
    end

    # Akcja aktualizująca kolejność i zagnieżdżenie stron. Wymagany parametr
    # :tree zawierający zserializowaną listę/drzewo z pluginu jquery-sortable.
    #
    # *PUT* /pages/sort
    #
    def sort
      authorize! :update, L::Page
      if L::Page.update_positions(params.fetch(:tree, {}))
        head :ok
      else
        head :unprocessable_entity
      end
    end

    # Akcja pozwalająca wykonać masowe operacje na zaznaczonych elementach.
    # Wymagane parametry to selection[ids] oraz selection[action].
    #
    # *POST* /admin/pages/selection
    #
    def selection
      authorize! :manage, L::Page
      selection = {
        action: params[:bulk_action],
        ids: params[:ids]
      }
      selection = L::Page.selection_object(selection)

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
