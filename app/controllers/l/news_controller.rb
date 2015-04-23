module L

  # Kontroler modułu aktualności.
  #
  # Pozwala na dodawanie, edycję i usuwanie aktualnosci.
  #
  class NewsController < ApplicationController
    layout "l/standard"

    # Akcja wyświetlająca listę aktualności. Dostępna dla mogących czytać newsy.
    #
    # *GET* /news
    #
    def index
      authorize! :read, L::News
      @news = L::News
        .ordered
        .visible
        .paginate page: params[:page]


      respond_to do |format|
        format.html
      end
    end

    # Akcja wyświetlająca pojedynczy news. Dostępna dla mogących czytać newsy.
    #
    # *GET* /news/1
    #
    def show
      @news = L::News.visible.find(params[:id])
      authorize! :read, @news

      respond_to do |format|
        format.html
      end
    end
    def show_draft
      @news = L::News::Draft.find(params[:news_id])

      #authorize! :read, @page

      respond_to do |format|
        format.html {render :show}
      end
    end
  end
end
