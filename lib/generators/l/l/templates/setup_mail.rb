config.action_mailer.raise_delivery_errors = true

config.action_mailer.default_url_options = { :host => 'localhost:3000' } 

config.action_mailer.delivery_method = :smtp

config.action_mailer.smtp_settings = {
  :address              => "mail.1000i.pl",
  :port                 => 587,
  :domain               => "1000i.pl",
  :user_name            => "test@1000i.pl",
  :password             => "test",
  :authentication       => "plain",
  :enable_starttls_auto => false
}

config.action_mailer.perform_deliveries = <%= @mailer_perform_deliveries.to_s %>;

