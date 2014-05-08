

  scope path: 'admin', as: :admin do
    scope module: :admin do
    end

    scope module: 'l/admin' do
      resources :users do
        collection do
          constraints(lambda {|req| req.params.has_key?(:ids)}) do
            delete :bulk_destroy, action: :selection, defaults: {bulk_action: :destroy}
            put :bulk_admin, action: :selection, defaults: {bulk_action: :make_admin}
            put :bulk_user, action: :selection, defaults: {bulk_action: :make_user}
          end
        end
      end
      get '', to: "admin#index"
    end
  end

  <%- if options.lang.length > 1 -%>
  match 'switch_lang/:lang', to: 'application#switch_lang', as:  :switch_lang
  <%- end -%>
  match 'search', to: 'application#search', as: :search
  root to: 'application#index'

