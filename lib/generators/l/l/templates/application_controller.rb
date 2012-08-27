class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to new_user_session_url, alert:  exception.message
  end
  rescue_from ActiveRecord::RecordNotFound do
    render action: "/shared/404"
  end


  protect_from_forgery
  <% if options.lang.length > 1 %>
  before_filter :default_url_options, :set_locale
  <% end %>
  layout :layout_by_resource

  def layout_by_resource
    if devise_controller?
      "l/layouts/admin_login"
    else
      "l/layouts/standard"
    end
  end


  def index
  end

  def search
  end
  <% if options.lang.length > 1 %>
  def switch_lang
    session[:locale] = params[:lang]
    render nothing:  true
  end
  <% end %>

  protected
  include L::FilterModule

  private
  <% if options.lang.length > 1 %>
  def set_locale
    if params[:locale]
      lang = params[:locale] || I18n.default_locale
      I18n.locale = lang.to_sym
    end
  end

  def default_url_options(options={})
    { locale:  I18n.locale }
  end
  <% end %>

  def after_sign_in_path_for(resource)
    "/admin"
  end
end

