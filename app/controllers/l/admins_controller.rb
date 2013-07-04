# coding: utf-8
module L

  # Kontroler zarządzania użytkownikiem.
  #
  class AdminsController < ApplicationController
    layout "l/layouts/admin"

    protect_from_forgery

    # Akcja pokazująca formularz edycji aktualnie zalogowanego użytkownika.
    #
    # *GET* /admin
    #
    def show
      authorize! :read, current_user

      respond_to do |format|
        format.html
      end
    end

    # Akcja aktualizująca dane aktualnie zalogowanego użytkownika.
    #
    # *POST* /admin/update_user
    #
    def update_user
      authorize! :update, current_user

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
