# encoding: utf-8
module L
  # Kotroler modułu stron stałych.
  #
  # Pozwala na dodawanie, edycje i usuwanie stron stałych. Używkonicy mogą
  # wyświetlać tylko pojedyncze strony.
  #
  class PagesController < ApplicationController
    uses_tinymce [:advance], only: [:new, :edit, :create, :update]
    layout "l/layouts/admin"

    # Akcja wyświetlająca listę istniejących stron w strukturze drzewiastej.
    #
    # *GET* /pages
    #
    def index
      authorize! :manage, :all
      @pages = L::Page.roots

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render xml: @pages }
      end
    end

    # Akcja wyświetlająca pojedynczą stronę, dostepna dla wszystkich. Domyślnie
    # dodawany jest routing dopasowujący dowolny niedopasowany ciąg znaków do
    # strony o takim tokenie.
    #
    # *GET* /pages/1
    #
    # *GET* /<i>token</i>
    # 
    def show
      if params[:token]
        @page = L::Page.find_by_token(params[:token])
      else
        @page = L::Page.find(params[:id])
      end

      render layout: '/l/layouts/standard'
    end

    # Akcja wyświetlająca formularz tworzenia nowej strony. Dostep tylko dla
    # administratora.
    #
    # *GET* /pages/new
    #
    def new
      authorize! :manage, :all
      @page = L::Page.new
      (I18n.available_locales).each {|locale|
        @page.translations.build locale: locale
      }
      @parents = L::Page.all

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render xml: @page }
      end
    end

    # Akcja wyświetlająca formularz edycji istniejącej strony. Dostępne tylko
    # dla administratora.
    #
    # *GET* /pages/1/edit
    #
    def edit
      authorize! :manage, :all
      @page = L::Page.find(params[:id])
      @parents = L::Page.where('`id` <> ?', @page.id).all 
    end

    # Akcja tworząca nową stronę. Dostęp tylko dla administratora.
    #
    # *POST* /pages
    #
    def create
      authorize! :manage, :all
      @page = L::Page.new(params[:l_page])
      @parents = L::Page.all


      respond_to do |format|
        if @page.save
          format.html { redirect_to(pages_url, notice: I18n.t('create.success')) }
          format.xml  { render xml: @page, status: :created, location: @page }
        else
          format.html { render action: "new" }
          format.xml  { render xml: @page.errors, status: :unprocessable_entity }
        end
      end
    end

    # Akcja aktualizująca istniejącą stronę. Dostępne tylko dla administratora.
    #
    # *PUT* /pages/1
    #
    def update
      authorize! :manage, :all
      @page = L::Page.find(params[:id])
      @parents = L::Page.all


      respond_to do |format|
        if @page.update_attributes(params[:l_page])
          format.html { redirect_to(pages_url, notice: I18n.t('update.success')) }
          format.xml  { head :ok }
        else
          format.html { render action: "edit" }
          format.xml  { render xml: @page.errors, status: :unprocessable_entity }
        end
      end
    end

    # Akcja usuwająca stronę. Dostępna tylko dla administratora.
    #
    # *DELETE* /pages/1
    #
    def destroy
      authorize! :manage, :all
      @page = L::Page.find(params[:id])
      @page.destroy

      respond_to do |format|
        format.html { redirect_to :back, notice: I18n.t('delete.success') }
        format.xml  { head :ok }
      end
    end

    # Akcja ukrywająca/pokazująca stronę. Dostępna tylko dla administratora
    #
    # *GET* /pages/1/hide
    #
    # *GET* /pages/1/unhide
    #
    def hide
      authorize! :manage, :all
      @page = L::Page.find(params[:id])

      status = params[:status].to_i || 1
      name = ['unhide', 'hide'][status]

      if @page.update_attribute(:hidden_flag, status)
        redirect_to :back, notice: I18n.t("#{name}.success")
      else
        redirect_to :back, notice: I18n.t("#{name}.failure")
      end
    end

    # Akcja pozwalająca zamienić kolejność stron. Wymaganym paarmetrem jest
    # +target_id+ - id strony wględem której wykonywana jest akcja. Dodatkowym
    # parametrem jest +method+ określający czy strona ma zostać
    # ustawiona jako potomek (wartość: +child+) lub wstawiona poniżej
    # wybranej storny w drzewie.
    #
    # *GET* /pages/1/switch
    #
    def switch
      authorize! :manage, :all
      target_page = L::Page.find(params[:target_id])
      page = L::Page.find(params[:id])

      status = case params[:method]
        when 'child' then page.set_parent!(target_page)
        else page.insert_after!(target_page)
      end

      render json: {success: status, errors: target_page.errors.full_messages }
    rescue ActiveRecord::RecordInvalid => ex
      render json: {success: false, errors: ex.record.errors.full_messages }
    end

  end
end
