module L
  module Concerns
    # Moduł rozszerzający klase uzytkownika. Dodaje domyślnie role (admin i user).
    # Automatycznie ładuje moduły devise'a [:database_authenticatable, :timeoutable,
    # :rememberable, :trackable, :registerable]. Dodaje accesible dla atrybutów:
    # :email, :password, :password_confirmation, :remember_me. Definuje walidacje
    # dla :email i :password.
    module LazyUser
      extend ActiveSupport::Concern

      included do 
        has_role :admin, :user, default: :user
        
        devise :database_authenticatable, :timeoutable,
               :rememberable, :trackable, :registerable

        attr_accessible :email, :password, :password_confirmation, :remember_me

        validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
        validates :password, presence: true, confirmation: true, length: {minimum: 5}
      end

    end
  end
end

