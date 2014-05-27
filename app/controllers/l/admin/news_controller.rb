module L::Admin

  # Kontroler modułu aktualności.
  #
  # Pozwala na dodawanie, edycję i usuwanie aktualnosci.
  #
  class NewsController < AdminController

    # Akcja wyświetlająca listę aktualności w panelu administracyjnym.
    #
    # *GET* /news
    #
    def index
      authorize! :manage, L::News

      @news = L::News
        .with_translations
        .filter(params[:filter])
      @news = @news.order(sort_order(:news)) if sort_results?
      @news = @news.paginate page: params[:page]

      respond_to do |format|
        format.html
        format.js
      end
    end

    # Akcja wyświetlająca formularz tworzenia nowego newsa. Dostępna tylko dla
    # administratora.
    #
    # *GET* /news/new
    #
    def new
      @news = L::News.new
      authorize! :create, @news

      respond_to do |format|
        format.html
        format.js
      end
    end

    # Akcja wyświetlająca formularz edycji istniejącego newsa. Dostępna tylko
    # dla administratora.
    #
    # *GET* /news/1/edit
    #
    def edit
      @news = L::News.find(params[:id])
      authorize! :update, @news

      respond_to do |format|
        format.html
        format.js
      end
    end

    # Akcja tworząca nowego newsa. Dostępna tylko dla administratora.
    #
    # *POST* /news
    #
    def create
      @news = L::News.new(params[:l_news])
      authorize! :create, @news

      @news.publish! if params.has_key?(:save_and_publish)
      @news.draft! if params.has_key?(:save_draft)

      respond_to do |format|
        if @news.save
          flash.notice = info(:success)
          format.html { redirect_to(admin_news_index_path) }
          format.js
        else
          format.html { render :action => "new" }
          format.js
        end
      end
    end

    # Akcja aktualizująca istniejącego newsa. Dostepna tylko dla
    # administratora.
    #
    # *PUT* /news/1
    #
    def update
      @news = L::News.find(params[:id])
      authorize! :update, @news

      respond_to do |format|
        if @news.update_attributes(params[:l_news])
          flash.notice = info(:success)
          format.html { redirect_to(admin_news_index_path) }
          format.js
        else
          format.html { render :action => "edit" }
          format.js
        end
      end
    end

    # Akcja usuwająca newsa. Dostepna tylko dla administratora.
    #
    # *DELETE* /news/1
    #
    def destroy
      @news = L::News.find(params[:id])
      authorize! :destroy, @news

      @news.destroy

      respond_to do |format|
        format.html { redirect_to admin_news_index_url, notice: info(:success) }
        format.js
      end
    end


    # Akcja pozwalająca wykonać masowe operacje na zaznaczonych elementach.
    # Wymagane parametry to selection[ids] oraz selection[action].
    #
    # *POST* /admin/pages/selection
    #
    def selection
      authorize! :manage, L::News
      selection = {
        action: params[:bulk_action],
        ids: params[:ids]
      }
      selection = L::News.selection_object(selection)

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
