  resources :users, controller: 'l/users' 
  resource :admin, controller: 'l/admins', only: [:show] do
    post :update_user, as: :update_user, on: member
  end

  <% if options.lang.length > 1 %>
  match 'switch_lang/:lang', to: 'application#switch_lang', as:  :switch_lang
  <% end %>
  match 'search', to: 'application#search', as: :search
  root to: 'application#index'

