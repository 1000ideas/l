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
    
    # Akcja wyświetlająca formularz edycji szkicu. Dostępne tylko
    # dla administratora.
    #
    # *GET* /news/1/edit_draft
    #
    def edit_draft
      @news = L::News.find(params[:id]).draft
      authorize! :update, @news
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
          @news.create_activity :create, owner: current_user
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
        if params.has_key?(:save_and_publish)
          @news.publish!

          if @news.update_attributes(params[:l_news])
            @news.create_activity :update, owner: current_user
            flash.notice = info(:success)
            format.html { redirect_to(admin_news_index_path) }
            format.js
          else
            format.html { render :action => "edit" }
            format.js
          end
        elsif params.has_key?(:create_draft)
          if @news.instantiate_draft!
            @news.draft.photo = @news.photo
            @news.draft.save
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
    # *put* /news/1
    #
    def update_draft
      @news = L::News::Draft.find(params[:id])
      authorize! :update, @news

      respond_to do |format|
      if params.has_key?(:save_draft)
        if @news.update_attributes(params[:l_news_draft])
          flash.notice = info(:success)
          format.html 
          format.js
        else
          format.html { render action: "edit_draft" }
          format.js
         end
      elsif params.has_key?(:delete_draft)
            @news = @news.news
            @news.destroy_draft! 
            format.html {redirect_to edit_admin_page_path(@news), notice: info(:success) }
            
      elsif params.has_key?(:publish_draft)
          @news = @news.news
          
          if @news.replace_with_draft!
            @news.photo = @news.draft.photo
            @news.save
            @news.destroy_draft!
            format.html {redirect_to edit_admin_news_path(@news), notice: info(:success) }
          else
              format.html { render action: "edit_draft" }
              format.js
          end
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
      @news.create_activity :destroy, owner: current_user

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
