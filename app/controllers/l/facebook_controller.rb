module L
  class FacebookController < ApplicationController
    protect_from_forgery
    before_filter :set_p3p, :sign_in_fb_user
    layout "l/layouts/facebook"

    private

    def sign_in_fb_user
      if request.post? and current_user.blank?
         redirect_to user_omniauth_authorize_path(:facebook, back_to: request.fullpath)
      elsif current_user.blank?
        redirect_to $fb_app_url
      end
    end

    def set_p3p
      headers['P3P'] = %|CP="NOI DSP COR CURa ADMa DEVa TAIa OUR BUS IND UNI COM NAV INT"|
    end

  end
end
