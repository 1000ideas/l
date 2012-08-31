# coding: utf-8
module L
  class NewsletterMailsController < ApplicationController
    uses_tinymce :advance, :only => [:send_mail_edit]
    layout "l/layouts/admin"
    
    def create
      require 'digest/sha1'
      token = Digest::SHA1.hexdigest(Time.now.to_s)
      @newsletter_mail = L::NewsletterMail.
        new(params[:l_newsletter_mail].merge(:confirm_token => token ))

      respond_to do |format|
        if @newsletter_mail.save
          Newsletter.confirmation(@newsletter_mail).deliver
          format.html {
            flash[:newsletter_notice_class] = 'notice'
            flash[:newsletter_notice] = I18n.t('newsletter.added')
            redirect_to :back
          }
          format.js
        else
          format.html {
            flash[:newsletter_notice_class] = 'alert'
            flash[:newsletter_notice] = @newsletter_mail.errors.full_messages.first
            redirect_to :back
          }
          format.js { render action: 'create_error' }
        end
      end
    end

    def confirm
      if L::NewsletterMail.confirm(params[:token])
        flash[:newsletter_notice_class] = 'notice'
        flash[:newsletter_notice] = I18n.t('newsletter.confirmed')
      else
        flash[:newsletter_notice_class] = 'alert'
        flash[:newsletter_notice] = I18n.t('newsletter.error')
      end
      redirect_to root_path
    end

    def index
      @newsletter_mail = L::NewsletterMail.where(:confirm_token => nil).
        paginate( :page => params[:page], :per_page => params[:per_page]||10 )
    end

    def send_mail_edit
      @emails = L::NewsletterMail.where(:confirm_token => nil).all
    end

    def send_mail
      if params[:emails].nil?
        flash[:alert] = "Nie wybrano odbiorców."
      else
        params[:emails].each do |email|
          Newsletter.send_mail(email, params[:text]).deliver
        end
        flash[:notice] = "Wysłano."
      end
      respond_to do |format|
        format.html { redirect_to(newsletter_mails_url) }
        format.xml  { head :ok }
      end
    end

    def destroy
      @newsletter_mail = L::NewsletterMail.find(params[:id])
      @newsletter_mail.destroy

      respond_to do |format|
        format.html { redirect_to(newsletter_mails_url) }
        format.xml  { head :ok }
      end
    end

  end
end
