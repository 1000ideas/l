  resources :users, :controller => 'l/users' 
  resource :admin, :controller => 'l/admins' do
    member do
      post :update_user, :as => :update_user
    end
  end

  <% if options.lang.length > 1 %>
  match 'switch_lang/:lang' => "application#switch_lang", :as => :switch_lang
  <% end %>
  #match 'search' => "application#search", :as => :search
  root :to => "application#index"

