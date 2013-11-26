# encoding: utf-8
module L::Concerns
	module Roles
		extend ActiveSupport::Concern

    module ClassMethods

      # Dodaj klasie (zwykle użytkownikowi) rolę, jedną z pośród 
      # podanych jako argumenty. Dodatkowe opcje wywołania:
      # 
      #  - +:shorthands+ - generuje metody ze znakiem zapytania, dla
      #    każdej podanej roli, np.: admin?, user?, która sprawadza
      #    czy podany użytkownik ma wybraną rolę. DOmyślnie te metody
      #    generowane, aby zablokować ustaw ten parametr na +false+.
      #  - +:default+ - domyślna rola użytkownika
      def has_role(*roles)
        common_adding_roles_actions(*roles)
        include OneRoleInstanceMethods

        class_eval do 
          attr_accessible :role
        end
      end

      # Dodaj klasie (zwykle użytkownikowi) role, może posiadać wiecej
      # niż jedną z pośród podanych jako argumenty. Dodatkowe opcje wywołania:
      # 
      #  - +:shorthands+ - generuje metody ze znakiem zapytania, dla
      #    każdej podanej roli, np.: admin?, user?, która sprawadza
      #    czy podany użytkownik ma wybraną rolę. DOmyślnie te metody
      #    generowane, aby zablokować ustaw ten parametr na +false+.
      #  - +:default+ - domyślna rola użytkownika
      def has_many_roles(*roles)
        common_adding_roles_actions(*roles)
        include ManyRolesInstanceMethods

        class_eval do 
          scope :with_only_roles,
            lambda {|*roles_names| where("roles_mask == :mask", mask: roles_names.sum {|r| role_mask(r)}) }

          scope :with_roles,
            lambda {|*roles_names| where("(roles_mask & :mask) == :mask", mask: roles_names.sum {|r| role_mask(r)}) }

          attr_accessible :roles
        end
      end

      # Dostępne role dla modelu
      def available_roles
        @_available_roles
      end

      # Domyślna rola użytkownika dla modelu
      def default_role
        @_default_role
      end

      # Lista roli do przekazania jako parametr pola +select+
      def roles_for_select
        available_roles.map do |r|
          [human_role_name(r), r]
        end
      end

      # Czytelna nazwa roli. Nazwy te definiowane są w I18n
      # w zakresie: helpers.roles.models.nazwa_modelu.nazwa_roli lub
      # helpers.roles.nazwa_roli
      #
      def human_role_name(role_name)
        if self.respond_to? :to_model
          key = "models.#{self.model_name.i18n_key}."
        end

        defaults = []
        defaults << role_name.to_sym if role_name
        defaults << role_name.to_s.titleize if role_name
        defaults << "Unknown" unless role_name

        I18n.t(:"#{key}#{role_name}", default: defaults, scope: 'helpers.roles')
      end

      private

      # Oblicz maskę bitową dla podanej roli. Wyrzuca +ArgumentError+ jeśli
      # dana rola nie jest zdefiniowana
      def role_mask(role_name)
        role_name = role_name.to_sym
        unless available_roles.include?(role_name)
          raise ArgumentError, "Undefined role :#{role_name} for #{self.class.name}"
        end
        2**available_roles.index(role_name)
      end

      # Wywołania inicjalizacyjne wspólne dla has_role i has_many_roles.
      def common_adding_roles_actions(*roles)
        options = roles.extract_options!

        @_available_roles = roles.map(&:to_sym)

        include CommonInstanceMethods

        shorthands = options[:shorthands].nil? ? true : options[:shorthands]

        if options[:default] && available_roles.include?(options[:default])
          @_default_role = options[:default]
        end

        available_roles.each do |role|
          define_method :"#{role}?" do
            self.has_role? role
          end
        end if shorthands



        class_eval do
          scope :with_role,
            lambda {|role_name| where("(roles_mask & :mask) = :mask", mask: role_mask(role_name)) }

          scope :with_only_role,
            lambda {|role_name| where("roles_mask  = :mask", mask: role_mask(role_name)) }

          scope :with_any_role,
            lambda {|*roles_names| where("(roles_mask & :mask) != 0", mask: roles_names.sum {|r| role_mask(r)}) }

          if default_role
            before_create :set_default_role

            def set_default_role
              if roles_mask.zero?
                write_attribute(:roles_mask, role_mask(self.class.default_role))
              end
            end

          end
        end

      end
    end

    # Metody dla modelu posiadającego jedną rolę.
    module OneRoleInstanceMethods

      # Pobierz rolę uzytkownika
      def role
        available_roles.find do |r|
          ! ((roles_mask || 0) & role_mask(r)).zero?
        end
      end

      # Pobierz czytelną nazwę roli użytkownika
      def human_role
        self.class.human_role_name(role) if role
      end

      # Ustaw rolę uzytkownika
      def role=(new_role)
        write_attribute(:roles_mask, role_mask(new_role))
      end
    end

    # Metody dla modelu posiadającego wiele ról.
    module ManyRolesInstanceMethods
      
      # Pobierz listę ról użytkownika
      def roles
        available_roles.find_all do |r|
          ! ((roles_mask || 0) & role_mask(r)).zero?
        end
      end

      # Pobierz listę czytelnych nazw ról użytkownika
      def human_roles
        roles.map do |r|
          self.class.human_role_name(r)
        end
      end

      # Ustaw (nadpisz) role użytkownika
      def roles=(new_roles)
        mask = (new_roles.map(&:to_sym) & available_roles).each {|r| role_mask(r) }.sum
        write_attribute(:roles_mask, mask)
      end

      # Dodaj rolę uzytkownikowi
      def give_role(role_name)
        write_attribute(:roles_mask, roles_mask | role_mask(role_name))
      end

      # Odbierz rolę użytkownikowi
      def take_role(role_name)
        write_attribute(:roles_mask, roles_mask & ~role_mask(role_name))
      end

      # Sprawdź czy użytkownik posiada wszyskie role z listy
      def has_all_roles?(*roles)
        roles.inject(true) do |mem, r|
          mem && self.has_role?(r)
        end
      end

    end

    # Metody wspólne dla modeli posiadaących jedną/wiele roli.
    module CommonInstanceMethods      

      # Lista dostepnych ról dla użytkownika
      def available_roles
        self.class.available_roles
      end

      # Sprawdza czy użytkownik posiada daną rolę.
      def has_role?(role_name)
        ! ((roles_mask || 0) & role_mask(role_name)).zero?
      end
      
      # Sprawdza czy użytkownik posiada choć jedną z podanych roli
      def has_any_role?(*roles)
        roles.inject(false) do |mem, r|
          mem || self.has_role?(r)
        end
      end

      private

      # Oblicz maskę bitową dla podanej roli. Wyrzuca +ArgumentError+ dla 
      # niezdefiniowanych roli
      def role_mask(role_name)
        self.class.send :role_mask, role_name
      end
    end

	end
end
