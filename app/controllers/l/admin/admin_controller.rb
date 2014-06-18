module L::Admin
  class AdminController < ApplicationController
    layout 'l/admin'

    def index
      authorize! :display, :dashboard

      @activities = PublicActivity::Activity
        .order('created_at DESC')
        .paginate page: params[:page], per_page: 20

      respond_to do |format|
        format.html
        format.js
      end
    end

  end
end
