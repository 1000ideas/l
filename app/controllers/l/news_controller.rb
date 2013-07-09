module L

  # Kontroler modułu aktualności.
  #
  # Pozwala na dodawanie, edycję i usuwanie aktualnosci.
  #
  class NewsController < ApplicationController
    uses_tinymce :simple, :only => [:new, :edit, :create, :update]
    layout "l/layouts/admin"
    
    # Akcja wyświetlająca listę aktualności w panelu administracyjnym.
    #
    # *GET* /news
    #
    def index
      @news = L::News
        .ordered
        .paginate page: params[:page]
      authorize! :menage, L::News

      respond_to do |format|
        format.html
      end
    end

    # Akcja wyświetlająca pojedynczy news. Dostępna dla mogących czytać newsy.
    #
    # *GET* /news/1
    #
    def show
      @news = L::News.find(params[:id])
      authorize! :read, @news

      render layout: "l/layouts/standard"
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
          format.html { redirect_to(news_index_url, :notice => I18n.t('create.success')) }
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
          format.html { redirect_to(news_index_url, :notice => I18n.t('update.success')) }
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
        format.html { redirect_to news_index_url, notice: t('destroy.success') }
        format.js
      end
    end

    # GET /news/list
    def list
      @news = L::News.paginate(page: params[:page], per_page: 5)
      authorize! :read, L::News

      render :layout => "l/layouts/standard"
    end
  end
end
