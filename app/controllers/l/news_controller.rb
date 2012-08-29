module L
  class NewsController < ApplicationController
    uses_tinymce :simple, :only => [:new, :edit, :create, :update]
    layout "l/layouts/admin"
    
    # GET /news
    # GET /news.xml
    def index
      authorize! :menage, :all
      @news = L::News.order("created_at DESC").
        paginate :page => params[:page], :per_page => params[:per_page]||10

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @news }
      end
    end

    # GET /news/1
    # GET /news/1.xml
    def show
      @news = L::News.find(params[:id])
      render :layout => "l/layouts/standard"
    end

    # GET /news/new
    # GET /news/new.xml
    def new
      authorize! :menage, :all
      @news = L::News.new
      (I18n.available_locales).each {|locale|
        @news.translations.build :locale => locale
      }

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @news }
      end
    end

    # GET /news/1/edit
    def edit
      authorize! :menage, :all
      @news = L::News.find(params[:id])
    end

    # POST /news
    # POST /news.xml
    def create
      authorize! :menage, :all
      @news = L::News.new(params[:l_news])

      respond_to do |format|
        if @news.save
          format.html { redirect_to(news_index_url, :notice => I18n.t('create.success')) }
          format.xml  { render :xml => @news, :status => :created, :location => @news }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @news.errors, :status => :unprocessable_entity }
        end
      end
    end

    # PUT /news/1
    # PUT /news/1.xml
    def update
      authorize! :menage, :all
      @news = L::News.find(params[:id])

      respond_to do |format|
        if @news.update_attributes(params[:l_news])
          format.html { redirect_to(news_index_url, :notice => I18n.t('update.success')) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @news.errors, :status => :unprocessable_entity }
        end
      end
    end

    # DELETE /news/1
    # DELETE /news/1.xml
    def destroy
      authorize! :menage, :all
      @news = L::News.find(params[:id])
      @news.destroy

      respond_to do |format|
        format.html { redirect_to news_index_url, notice: t('destroy.success') }
        format.xml  { head :ok }
        format.js
      end
    end

    # GET /news/list
    def list
      @news = L::News.
        order("created_at DESC").
        paginate :page => params[:page], :per_page => params[:per_page] || 5
      render :layout => "l/layouts/standard"
    end
  end
end
