# coding: utf-8
module L
  class UsersController < ApplicationController
    layout "l/layouts/admin"

    def index
      authorize! :menage, :all
      @users = User.all.paginate :page => params[:page], :per_page => params[:per_page]||10
    end

    def show
      authorize! :menage, :all
      @user = User.find(params[:id])
    end

    def new
      authorize! :menage, :all
      @user = User.new
    end

    def edit
      authorize! :menage, :all
      @user = User.find(params[:id])
    end

    def create
      authorize! :menage, :all
      @user = User.new(params[:user])
      if @user.save
        redirect_to users_path, notice: I18n.t('create.success')
      else
        render :action => :new
      end
    end

    def update
      authorize! :menage, :all
      @user = User.find(params[:id])
      if @user.update_attributes(params[:user])
        redirect_to users_path, notice: I18n.t('update.success')
      else
        render :action => :edit
      end
    end

    def destroy
      authorize! :menage, :all
      @user = User.find(params[:id])
      @user.destroy
      respond_to do |format|
        format.html { redirect_to :back, notice: t('delete.success') }
        format.js
      end
    end

  end
end
