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
    layout "l/facebook"

    protected

    # Zaloguj użytkownika facebookowego do aplikacji, jeśli żaden nie jest
    # zalogowany.
    def sign_in_fb_user
      if request.post? and current_user.blank?
        if parsed_signed_request.has_key?('oauth_token')
          redirect_to user_omniauth_authorize_path(:facebook)
        else
          render text: %(<script type="text/javascript">top.location.href = "#{user_omniauth_authorize_path(:facebook)}"</script>)
        end
      elsif current_user.blank?
        redirect_to $fb_app_url
      end
    end

    # Ustaw nagłówki P3P, tak aby aplikacja mogła zapisywać cookie w ramce w
    # IE.
    def set_p3p
      headers['P3P'] = %|CP="NOI DSP COR CURa ADMa DEVa TAIa OUR BUS IND UNI COM NAV INT"|
    end

    def parsed_signed_request
      if request.post? and params.has_key?('signed_request')
        Koala::Facebook::OAuth.new($fb_app_id, $fb_app_secret)
          .parse_signed_request(params['signed_request'])
      end || {}
    end

    def sign_in_from_signed_request
      if (token = parsed_signed_request['oauth_token'])
        if (user = Authentication.where(token: token).first.try(:user))
          sign_in user
        end
      end
    end
  end
end
