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
        
        attr_accessor :updated_by
        attr_accessible :email, :password, :password_confirmation, :remember_me,
          :updated_by

        private

        def updated_by_admin?
          updated_by.present? and updated_by.admin?
        end

        def password_required?
          super && !updated_by_admin?
        end
      end
    end
  end
end

