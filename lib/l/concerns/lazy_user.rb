module L
  module Concerns
    # Moduł rozszerzający klase uzytkownika. Dodaje domyślnie role (admin i user).
    # Automatycznie ładuje moduły devise'a [:database_authenticatable, :timeoutable,
    # :rememberable, :trackable, :registerable, :validatable]. Dodaje accesible dla atrybutów:
    # :email, :password, :password_confirmation, :remember_me.
    module LazyUser
      extend ActiveSupport::Concern

      included do
        acts_as_paranoid

        has_role :admin, :user, default: :user

        devise :database_authenticatable, :timeoutable,
               :rememberable, :trackable, :registerable,
               :validatable

        attr_accessor :updated_by
        attr_accessible :email, :password, :password_confirmation, :remember_me,
          :updated_by

        set_mass_actions :destroy, :make_admin, :make_user
        define_perform_action(:make_admin) { role_for_all(:admin) }
        define_perform_action(:make_user) { role_for_all(:user) }

        scope :filter_by_email, lambda {|mail| where("`#{table_name}`.`email` LIKE ?", "%#{mail}%")}
        scope :filter_by_role, lambda {|role| with_role(role) }

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

