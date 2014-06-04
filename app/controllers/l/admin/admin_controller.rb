module L::Admin
  class AdminController < ApplicationController
    layout 'l/admin'

    def index
      authorize! :display, :dashboard

      respond_to do |format|
        format.html
      end
    end

  end
end
