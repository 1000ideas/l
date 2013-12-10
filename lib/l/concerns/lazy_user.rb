module L
  module Concerns
    # Moduł rozszerzający klase uzytkownika. Dodaje domyślnie role (admin i user).
    # Automatycznie ładuje moduły devise'a [:database_authenticatable, :timeoutable,
    # :rememberable, :trackable, :registerable, :validatable]. Dodaje accesible dla atrybutów:
    # :email, :password, :password_confirmation, :remember_me.
    module LazyUser
      extend ActiveSupport::Concern

      included do 
        has_role :admin, :user, default: :user
        
        devise :database_authenticatable, :timeoutable,
               :rememberable, :trackable, :registerable,
               :validatable

        attr_accessible :email, :password, :password_confirmation, :remember_me

        end

    end
  end
end

