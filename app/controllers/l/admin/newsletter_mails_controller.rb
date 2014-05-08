# encoding: utf-8
module L::Admin
  # Kontroler modułu newslettera.
  #
  # Pozwala na wysyłanie listów do zapisanych osób. Dodawanie, potwierdzanie i
  # usuwanie osób z listy.
  #
  class NewsletterMailsController < AdminController

    # Akcja wyświetlająca liste zapisanych i potwierdzonych adresów email.
    # Dostępna tylko dla administratora.
    #
    # *GET* /newsletter_mails
    #
    def index
      authorize! :manage, L::NewsletterMail
      @newsletter_mail = L::NewsletterMail

      @newsletter_mail = @newsletter_mail.filter(params[:filter])

      @newsletter_mail = if params[:unconfirmed]
        ::Rails.logger.debug "UNCONFIRMED"
        @newsletter_mail.where("`confirm_token` IS NOT NULL")
      else
        @newsletter_mail.confirmed
      end

      @newsletter_mail = @newsletter_mail.order(sort_order) if sort_results?
      @newsletter_mail = @newsletter_mail.paginate(page: params[:page])

      respond_to do |format|
        format.html
        format.js
      end
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
        format.html { redirect_to(admin_newsletter_mails_path, notice: info(:success)) }
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
        format.html { redirect_to(:back, notice: info(:success) ) }
      end
    end

    # Akcja pozwalająca potwierdzić wybrany adres. Dostępna tylko dla
    # administratora.
    #
    # *DELETE* /newsletter_mails/1/confirm
    #
    def confirm
      @newsletter_mail = L::NewsletterMail.find(params[:id])
      authorize! :destroy, @newsletter_mail
      @newsletter_mail.confirm

      respond_to do |format|
        format.html { redirect_to(:back, notice: info(:success) ) }
      end
    end


    # Akcja pozwalająca wykonać masowe operacje na zaznaczonych elementach.
    # Wymagane parametry to selection[ids] oraz selection[action].
    #
    # *POST* /admin/newsletter_mail/selection
    #
    def selection
      authorize! :manage, L::NewsletterMail
      selection = {
        action: params[:bulk_action],
        ids: params[:ids]
      }
      selection = L::NewsletterMail.selection_object(selection)

      respond_to do |format|
        if selection.perform!
          format.html { redirect_to :back, notice: info(selection.action, :success) }
        else
          format.html { redirect_to :back, alert: info(selection.action, :failure) }
        end
      end
    end

  end
end
