module L::Concerns
	module Roles
		extend ActiveSupport::Concern

    module ClassMethods

      def has_role(*roles)
        common_adding_roles_actions(*roles)
        include OneRoleInstanceMethods
      end

      def has_many_roles(*roles)
        common_adding_roles_actions(*roles)
        include ManyRolesInstanceMethods

        class_eval do 
          scope :with_only_roles,
            lambda {|*roles_names| where("roles_mask == :mask", mask: roles_names.sum {|r| role_mask(r)}) }

          scope :with_roles,
            lambda {|*roles_names| where("(roles_mask & :mask) == :mask", mask: roles_names.sum {|r| role_mask(r)}) }
        end
      end

      def available_roles
        @_available_roles
      end

      def human_role_name(role_name)
        if self.respond_to? :to_model
          key = "#{self.model_name.i18n_key}."
        end
        t("#{key}#{role_name}", default: [role_name.to_sym, role_name.to_s.titleize], scope: 'helpers.roles')
      end

      def role_mask(role_name)
        role_name = role_name.to_sym
        unless available_roles.include?(role_name)
          raise ArgumentError, "Undefined role :#{role_name} for #{self.class.name}"
        end
        2**available_roles.index(role_name)
      end

      private

      def common_adding_roles_actions(*roles)
        options = roles.extract_options!

        @_available_roles = roles.map(&:to_sym)

        include InstanceMethods

        shorthands = options[:shorthands].nil? ? true : options[:shorthands]

        available_roles.each do |role|
          define_method :"#{role}?" do
            self.has_role? role
          end
        end if shorthands

        class_eval do
          scope :with_role,
            lambda {|role_name| where("(roles_mask & :mask) == :mask", mask: role_mask(role_name)) }

          scope :with_only_role,
            lambda {|role_name| where("roles_mask  == :mask", mask: role_mask(role_name)) }

          scope :with_any_role,
            lambda {|*roles_names| where("(roles_mask & :mask) != 0", mask: roles_names.sum {|r| role_mask(r)}) }

          attr_accessible :roles
        end

      end
    end

    module OneRoleInstanceMethods
      def role
        available_roles.find do |r|
          ((roles_mask || 0) & role_mask(r)).nonzero? == 1
        end
      end

      def human_role
        self.class.human_role_name(role)
      end

      def role=(new_role)
        write_attribute(:roles_mask, role_mask(new_role))
      end
    end

    module ManyRolesInstanceMethods
      

      def roles
        available_roles.find_all do |r|
          ((roles_mask || 0) & role_mask(r)).nonzero? == 1
        end
      end

      def human_roles
        roles.map do |r|
          self.class.human_role_name(r)
        end
      end

      def roles=(new_roles)
        mask = (new_roles.map(&:to_sym) & available_roles).each {|r| role_mask(r) }.sum
        write_attribute(:roles_mask, mask)
      end

      def give_role(role_name)
        write_attribute(:roles_mask, roles_mask | role_mask(role_name))
      end

      def take_role(role_name)
        write_attribute(:roles_mask, roles_mask & ~role_mask(role_name))
      end

      def has_all_roles?(*roles)
        roles.inject(true) do |mem, r|
          mem && self.has_role?(r)
        end
      end

    end

    module InstanceMethods      

      def available_roles
        self.class.available_roles
      end

      def has_role?(role_name)
        ((roles_mask || 0) & role_mask(role_name)).nonzero? == 1 
      end
      
      def has_any_role?(*roles)
        roles.inject(false) do |mem, r|
          mem || self.has_role?(r)
        end
      end

      private

      def role_mask(role_name)
        self.class.role_mask(role_name)
      end
    end

	end
end
