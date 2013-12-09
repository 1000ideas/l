module L::Admin
  class AdminController < ApplicationController
    layout 'l/admin'

    def index
      respond_to do |format|
        format.html
      end
    end

  end
end