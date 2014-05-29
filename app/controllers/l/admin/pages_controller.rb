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

      @parents = L::Page.where('`id` <> ?', @page.id).all
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
        if @page.update_attributes(params[:l_page])
          flash.notice = info(:success)
          format.html { redirect_to(admin_pages_path) }
          format.js
        else
          format.html { render action: "edit" }
          format.js
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
          format.html { redirect_to :back, notice: info(selection.action, :success) }
        else
          format.html { redirect_to :back, alert: info(selection.action, :failure) }
        end
      end
    end

  end
end
