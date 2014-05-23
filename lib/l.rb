require 'l/rails'
require 'middleware/flash_session_cookie_middleware'
require 'devise'
require 'paperclip'
require 'tinymce-rails'
require 'jquery-ui-rails'
require 'jquery-fileupload-rails'
require 'foundation-rails'
require 'font-awesome-rails'
require 'paranoia'

if Rails.env.development?
  require 'better_errors'
  require 'binding_of_caller'
  require 'quiet_assets'
end

TinyMCE.config do |config|
  config.default_skin = :lazy
end

ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| html_tag }
