#encoding: utf-8

$fb_scope = "email,user_likes"

if Rails.env == "production"
  $fb_app_id = ""
  $fb_app_secret = ""
  $fb_app_host = ""
  $fb_app_url = ""
  $app_host = $fb_app_host
else
  $fb_app_id = "144904922243267"
  $fb_app_secret = "5e777fa78f8b3d3d9804c81f5f0a3219"
  $fb_app_host = "http://localhost:3000/facebook/"
  $fb_app_url = "https://apps.facebook.com/test_local_rails_ti/"
  $app_host = "http://localhost:3000/"
end


OmniAuth.config.full_host = $app_host

