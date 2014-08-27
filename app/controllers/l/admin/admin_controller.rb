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

    def settings
      if request.put?
        _settings.update_attributes(params[:settings])
      end

      respond_to do |format|
        format.html
      end
    end

  end
end
