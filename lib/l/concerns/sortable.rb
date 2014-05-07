module L
  module Concerns
    module Sortable
      extend ActiveSupport::Concern

      module Helper
        def self.update_positions(klass, tree, parent = nil, options = {})
          _column = options[:column]
          _scope = options[:scope]
          tree.each do |position, object|
            if _scope
              attrs = Hash[_scope.zip([*parent])]
              attrs[:"#{_column}"] = position
              klass.where(id: object[:id]).update_all(attrs)
              if object[:children] and object[:children]['0']
                update_positions(klass, object[:children]['0'], object[:id], options)
              end
            else
              klass.where(id: object[:id]).update_all(:"#{_column}" => position)
            end
          end
        end
      end

      module ClassMethods

        # Model może być ręcznie sortowany według podanej kolumny (domyslnie +:position+)
        # Dodaje do instancji modelu metody pozwalające na zmianę kolejności. Do poprawnego
        # działania należy pobierać elementy z modelu za pomocą scope'a: +ordered+.
        #
        # Możliwe opcje:
        # - +:scope+ - uwzględniaj zakres w którym ma następować określanie
        # pozycji (przydatne przy modelach act_as_tree, albo modelach należacych do róznych użytkowników)
        # - +:column+ - nazwa kolumny, domyślnie position lub pierwszy argument
        # - +:direction+ - domyślny porządek sortowania, możliwe wartości to +:asc+ i +:desc+. DOmyślnie +:asc+
        #
        def sortable(*options)
          opts = options.extract_options!
          _column = options.first || opts[:column] || :position

          _scope = [*opts[:scope]].compact.map(&:to_sym)

          _direction = (opts[:direction] || :asc).to_sym
          _direction = :asc unless _direction.in? [:asc, :desc]

          self.class_variable_set "@@_sortable_options", {
            column: _column,
            scope: _scope,
            direction: _direction
          }

          include InstanceMethods

          class_eval do
            scope :ordered, order("`#{table_name}`.`#{_column}` #{_direction.to_s.upcase}")

            def self.update_positions(tree)
              self.transaction do
                Helper.update_positions(self, tree, nil, sortable_options)
              end
            end
          end
        end

        def sortable?
          self.sortable_options.is_a? Hash
        end

        def sortable_options
          self.class_variable_get("@@_sortable_options")
        end

      end

      module InstanceMethods

        def sortable?
          self.class.sortable?
        end
      end
    end
  end
end
