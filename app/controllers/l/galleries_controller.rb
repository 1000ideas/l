# coding: utf-8
module L

  class GalleriesController < ApplicationController

    layout "l/layouts/admin"
  
    uses_tinymce :simple, :only => [:new, :edit, :create, :update]

    # GET /galleries
    # GET /galleries.xml
    def index
      @galleries = L::Gallery.
        paginate :page => params[:page], :per_page => params[:per_page]||10

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @galleries }
      end
    end

    # GET /galleries/1
    # GET /galleries/1.xml
    def show
      @gallery = L::Gallery.find(params[:id])

      render :layout => "l/layouts/standard"
    end

    # GET /galleries/new
    # GET /galleries/new.xml
    def new
      @gallery = L::Gallery.new
      (I18n.available_locales).each {|locale|
        @gallery.translations.build :locale => locale
      }
      @parents = L::Gallery.all

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @gallery }
      end
    end

    # GET /galleries/1/edit
    def edit
      @gallery = L::Gallery.find(params[:id])
      @gallery_photos = @gallery.gallery_photos

    end

    # POST /galleries
    # POST /galleries.xml
    def create
      @gallery = L::Gallery.new(params[:l_gallery])

      respond_to do |format|
        if @gallery.save
          format.html { redirect_to(edit_gallery_path(@gallery), :notice => I18n.t('create.success')) }
          format.xml  { render :xml => @gallery, :status => :created, :location => @gallery }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @gallery.errors, :status => :unprocessable_entity }
        end
      end
    end

    # PUT /galleries/1
    # PUT /galleries/1.xml
    def update
      @gallery = L::Gallery.find(params[:id])

      respond_to do |format|
        if @gallery.update_attributes(params[:l_gallery])
          format.html { redirect_to(galleries_path, :notice => I18n.t('update.success')) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @gallery.errors, :status => :unprocessable_entity }
        end
      end
    end

    # GET /news/list
    def list
      @gallery = L::Gallery.all.paginate :page => params[:page], :per_page => params[:per_page]||5
      render :layout => "l/layouts/standard"
    end

    def destroy
      @gallery = L::Gallery.find(params[:id])
      @gallery.destroy

      respond_to do |format|
        format.html { redirect_to(galleries_path) }
        format.xml  { head :ok }
      end
    end

  end
end
