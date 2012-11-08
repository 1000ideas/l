
  # ==> OmniAuth
  # Add a new OmniAuth provider. Check the wiki for more information on setting
  # up on your models and hooks.
  ssl_options = {
    :ca_file => Rails.root.join("config", "ca-bundle.crt").to_s 
  }

  config.omniauth :facebook, 
    $fb_app_id, 
    $fb_app_secret, 
    :scope => $fb_scope,
    :client_options => {:ssl => ssl_options }

