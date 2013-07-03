module L
  module Controllers
    module ExceptionsRescues
      extend ActiveSupport::Concern

      included do 
        rescue_from CanCan::AccessDenied, with: :rescue_from_access_denied
        rescue_from ActiveRecord::RecordNotFound, with: :rescue_from_not_found
      end

      protected

      # Odpowiedź na zabroniony dostęp do jakiejś akcji,
      # wystarczy nadpisać w dowolnym kontrolerze 
      #
      # Parametry:
      #   - +ex+ - obsługiwany wyjątek
      #
      def rescue_from_access_denied(ex)
        respond_to do |format|
          format.html do
            if current_user.nil?
              redirect_to new_user_session_url, alert:  ex.message
            else
              begin
                redirect_to :back, alert: ex.message
              rescue ActionController::RedirectBackError
                redirect_to root_path, alert: ex.message
              end
            end
          end
          format.any do
            head :unauthorized, warning: ex.message
          end
        end
      end

      # Odpowiedź na brak rekodru w jakiejś akcji,
      # wystarczy nadpisać w dowolnym kontrolerze 
      #
      # Parametry:
      #   - +ex+ - obsługiwany wyjątek
      #
      def rescue_from_not_found(ex)
        respond_to do |format|
          format.html do
            @exception = ex
            render action: "404", status: 404
          end
          format.any do
            head :not_found, warning: ex.message
          end
        end
      end

    end
  end
end