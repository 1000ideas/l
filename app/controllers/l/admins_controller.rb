# coding: utf-8
module L
  class AdminsController < ApplicationController
    layout "l/layouts/admin"

    protect_from_forgery

    def show
      authorize! :manage, :self
    end

    def update_user
      authorize! :manage, :self

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
