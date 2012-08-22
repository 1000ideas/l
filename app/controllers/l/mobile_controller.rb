# coding: utf-8
module L
  class MobileController < ApplicationController
    skip_before_filter :mobile_subdomain
    layout "l/layouts/mobile"

    rescue_from ActiveRecord::RecordNotFound do
      render :action => "lazy_programmer/mobile/error404"
    end
    
    rescue_from CanCan::AccessDenied do
      render :action => "lazy_programmer/mobile/error401"
    end

    def index
    end

  end
end
