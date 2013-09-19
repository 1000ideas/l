# coding: utf-8
module L
  # Kontroler modułu newslettera.
  #
  # Pozwala na wysyłanie listów do zapisanych osób. Dodawanie, potwierdzanie i
  # usuwanie osób z listy.
  #
  class NewsletterMailsController < ApplicationController        
    # Akcja pozwalająca zapisać się do newslettera.
    #
    # *POST* /newsletter_mails
    #
    def create
      @mail = L::NewsletterMail.new(params[:l_newsletter_mail])
      authorize! :create, @mail

      respond_to do |format|
        if @mail.save
          Newsletter.confirmation(@mail).deliver
          format.html {
            flash[:newsletter_notice] = I18n.t('newsletter.added')
            redirect_to :back
          }
        else
          format.html {
            flash[:newsletter_alert] = @mail.errors.full_messages.first
            redirect_to :back
          }
        end
        format.js
      end
    rescue ActionController::RedirectBackError
      redirect_to root_path
    end

    # Akcja pozwalająca potwierdzi zapisany adres email. Wymagany parametr
    # +token+.
    #
    # *GET* /newsletter_mail/confirm
    #
    def confirm
      @mail = L::NewsletterMail.find_by_confirm_token(params[:token])
      authorize! :create, @mail

      if @mail.try(:confirm)
        flash[:newsletter_notice] = I18n.t('newsletter.confirmation.confirmed')
      else
        flash[:newsletter_alert] = I18n.t('newsletter.confirmation.error')
      end
      
      redirect_to root_path
    end


  end
end
