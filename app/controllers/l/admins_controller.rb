# coding: utf-8
module L
  class AdminsController < ApplicationController
    layout "l/layouts/admin"

    protect_from_forgery

    rescue_from CanCan::AccessDenied do
      redirect_to new_user_session_path
    end

    def show
      authorize! :read, :all
    end

    def update_user
      logger.debug
      authorize! :read, :all

      respond_to do |format|

        if current_user.update_attributes(params[:user])
          format.html { redirect_to(admin_path, :notice => I18n.t('update.success')) }
          format.xml  { head :ok }
        else
          format.html { render :action => "show" }
          format.xml  { render :xml => current_user.errors, :status => :unprocessable_entity }
        end

      end
    end
  end
end
