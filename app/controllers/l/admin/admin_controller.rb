module L::Admin
  class AdminController < ApplicationController
    layout 'l/admin'

    def index
      authorize! :manage, User
      
      respond_to do |format|
        format.html
      end
    end

  end
end