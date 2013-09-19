module L::Admin

  # Kontroler modułu aktualności.
  #
  # Pozwala na dodawanie, edycję i usuwanie aktualnosci.
  #
  class NewsController < AdminController
    uses_tinymce :simple, :only => [:new, :edit, :create, :update]
    
    # Akcja wyświetlająca listę aktualności w panelu administracyjnym.
    #
    # *GET* /news
    #
    def index
      authorize! :manage, L::News
      
      @news = L::News
        .ordered
        .paginate page: params[:page]

      respond_to do |format|
        format.html
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

      (I18n.available_locales).each {|locale|
        @news.translations.build :locale => locale
      }

      respond_to do |format|
        format.html
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
      end
    end

    # Akcja tworząca nowego newsa. Dostępna tylko dla administratora.
    #
    # *POST* /news
    #
    def create
      @news = L::News.new(params[:l_news])
      authorize! :create, @news

      respond_to do |format|
        if @news.save
          format.html { redirect_to(admin_news_index_path, :notice => I18n.t('create.success')) }
        else
          format.html { render :action => "new" }
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
          format.html { redirect_to(admin_news_index_path, :notice => I18n.t('update.success')) }
        else
          format.html { render :action => "edit" }
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
        format.html { redirect_to admin_news_index_url, notice: t('destroy.success') }
        format.js
      end
    end

  end
end
