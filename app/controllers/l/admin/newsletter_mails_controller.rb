# encoding: utf-8
module L::Admin
  # Kontroler modułu newslettera.
  #
  # Pozwala na wysyłanie listów do zapisanych osób. Dodawanie, potwierdzanie i
  # usuwanie osób z listy.
  #
  class NewsletterMailsController < AdminController
    uses_tinymce :advance, :only => [:send_mail_edit]
    
    # Akcja wyświetlająca liste zapisanych i potwierdzonych adresów email.
    # Dostępna tylko dla administratora.
    #
    # *GET* /newsletter_mails
    #
    def index
      authorize! :manage, L::NewsletterMail
      @newsletter_mail = L::NewsletterMail
        .ordered
        .where(:confirm_token => nil)
        .paginate page: params[:page]
    end

    # Akcja wyświetlająca formularz nowego listu newslettera. Dostępna tylko
    # dla administratora.
    #
    # *GET* /newsletter_mails/send_mail
    #
    def send_mail_edit
      authorize! :manage, L::NewsletterMail
      @emails = L::NewsletterMail.where(:confirm_token => nil).all

      if @emails.empty?
        redirect_to({action: :index}, notice: t('no_mails', scope: 'l.newsletter_mails.form')) and return
      end

      respond_to do |format|
        format.html { render action: :send_mail }
      end
    end

    # Akcja sprawdza i wysyła newsleter do wybranych użytkowników. Dostepna
    # tylko dla administratora.
    #
    # *POST* /newsletter_mails/send_mail
    #
    def send_mail
      authorize! :manage, L::NewsletterMail
      if params[:emails].nil?
        flash[:alert] = t('newsletter.send_mail.no_emails')
      else
        params[:emails].each do |email|
          Newsletter.send_mail(email, params[:text]).deliver
        end
        flash[:notice] = t('newsletter.send_mail.sended', count: params[:emails].count)
      end
      respond_to do |format|
        format.html { redirect_to(admin_newsletter_mails_path) }
      end
    end

    # Akcja pozwalająca usunąć adres z listy mailingowej. Dostępna tylko dla
    # administratora.
    #
    # *DELETE* /newsletter_mails/1
    #
    def destroy
      @newsletter_mail = L::NewsletterMail.find(params[:id])
      authorize! :destroy, @newsletter_mail
      @newsletter_mail.destroy

      respond_to do |format|
        format.html { redirect_to( admin_newsletter_mails_path ) }
      end
    end

  end
end
