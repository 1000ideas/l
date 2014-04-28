require 'l/rails'
require 'middleware/flash_session_cookie_middleware'
require 'devise'
require 'paperclip'
require 'jquery-ui-rails'
require 'jquery-fileupload-rails'
require 'foundation-rails'
require 'font-awesome-rails'

if Rails.env.development?
  require 'better_errors'
  require 'binding_of_caller'
  require 'quiet_assets'
end
