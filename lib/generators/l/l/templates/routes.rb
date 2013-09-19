
  scope path: 'admin', as: :admin do
    scope module: 'l/admin' do
      resources :users
    end

    get '', to: 'devise/registrations#edit', constraints: lambda { |request|  request.env["devise.mapping"] = Devise.mappings[:user]; true }
  end

  <%- if options.lang.length > 1 -%>
  match 'switch_lang/:lang', to: 'application#switch_lang', as:  :switch_lang
  <%- end -%>
  match 'search', to: 'application#search', as: :search
  root to: 'application#index'

