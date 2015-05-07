# encoding: utf-8
module L
  # Kotroler modułu stron stałych.
  #
  # Pozwala na dodawanie, edycje i usuwanie stron stałych. Używkonicy mogą
  # wyświetlać tylko pojedyncze strony.
  #
  class PagesController < ApplicationController
    layout "l/standard"

    # Akcja wyświetlająca pojedynczą stronę, dostepna dla wszystkich. Domyślnie
    # dodawany jest routing dopasowujący dowolny niedopasowany ciąg znaków do
    # strony o takim tokenie.
    #
    # *GET* /pages/1
    # *GET* /<i>token</i>
    # 
    def show
      if params[:token]
        @page = L::Page.find_by_token(params[:token])
      else
        @page = L::Page.find(params[:id])
      end
      @page_original = @page
      authorize! :read, @page

      respond_to do |format|
        format.html
      end
    end

    def show_draft

      if params[:id]
        @page = L::Page::Draft.find(params[:id])
      end
      @page_original = @page.page
      
      #authorize! :read, @page

      respond_to do |format|
        format.html {render :show}
      end
    end
  end
end
