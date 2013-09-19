# coding: utf-8
module L
  # Kontroler mobilny. Wszystkie kontrolery obsługujące akcje mobilne powinny
  # dziedziczyć po tym kontrolerze.
  #
  class MobileController < ApplicationController
    skip_before_filter :mobile_subdomain
    layout "l/mobile"

    rescue_from ActiveRecord::RecordNotFound do
      render :action => "l/mobile/error404"
    end
    
    rescue_from CanCan::AccessDenied do
      render :action => "l/mobile/error401"
    end

    # Akcja główna kontrolerza mobilnego.
    #
    # *GET* m.example.com/
    def index
    end

  end
end
