# encoding: utf-8
module L
  class PagesController < ApplicationController
    uses_tinymce [:advance], only: [:new, :edit, :create, :update]
    layout "l/layouts/admin"

    def index
      authorize! :manage, :all
      @pages = L::Page.roots

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render xml: @pages }
      end
    end

    # GET /pages/1
    # GET /pages/1.xml
    def show
      if params[:token]
        @page = L::Page.find_by_token(params[:token])
        raise ActiveRecord::RecordNotFound unless @page
      else
        @page = L::Page.find(params[:id])
      end

      render layout: '/l/layouts/standard'
    end

    # GET /pages/new
    # GET /pages/new.xml
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

    # GET /pages/1/edit
    def edit
      authorize! :manage, :all
      @page = L::Page.find(params[:id])
      @parents = L::Page.where('`id` <> ?', @page.id).all 
    end

    # POST /pages
    # POST /pages.xml
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

    # PUT /pages/1
    # PUT /pages/1.xml
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

    # DELETE /pages/1
    # DELETE /pages/1.xml
    def destroy
      authorize! :manage, :all
      @page = L::Page.find(params[:id])
      @page.destroy

      respond_to do |format|
        format.html { redirect_to :back, notice: I18n.t('delete.success') }
        format.xml  { head :ok }
      end
    end

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

    def switch
      authorize! :manage, :all
      where_page = L::Page.find(params[:new_id])
      page = L::Page.find(params[:id])
      logger.debug params[:switch_action]
      if params[:switch_action] == 'as_child'
        unless where_page.ancestor?(page) or page.id == where_page.id
          page.change_parent(where_page)
          render json: {success: true}
        else
          render json: {success: false}
        end
      elsif page.parent_id == where_page.parent_id
        page.drop_after(where_page)
        render json: {success: true}
      elsif not where_page.ancestor?(page)
        page.set_sibling_and_drop_after(where_page)
        render json: {success: true}
      else
        render json: {success: false}
      end
      expires_now
    end

  end
end
