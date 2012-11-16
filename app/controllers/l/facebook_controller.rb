module L
  # Kontroler wszystkich akcji facebookowych.
  #
  # W aplikacji dziedziczy po nim FacebookController, a po nim powinien
  # dziedziczyć każdy kontroler obsługujący akcje aplikacji facebookowej na
  # płótnie (canvas).
  #
  class FacebookController < ApplicationController
    protect_from_forgery
    before_filter :set_p3p, :sign_in_fb_user
    layout "l/layouts/facebook"

    protected

    # Zaloguj użytkownika facebookowego do aplikacji, jeśli żaden nie jest
    # zalogowany.
    def sign_in_fb_user
      if request.post? and current_user.blank?
         redirect_to user_omniauth_authorize_path(:facebook, back_to: request.fullpath)
      elsif current_user.blank?
        redirect_to $fb_app_url
      end
    end

    # Ustaw nagłówki P3P, tak aby aplikacja mogła zapisywać cookie w ramce w
    # IE.
    def set_p3p
      headers['P3P'] = %|CP="NOI DSP COR CURa ADMa DEVa TAIa OUR BUS IND UNI COM NAV INT"|
    end

  end
end
