module L
  module Concerns
    module Sortable
      extend ActiveSupport::Concern

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

          @@_sortable_options = {
            column: _column,
            scope: _scope,
            direction: _direction
          }
       
          include InstanceMethods

          class_eval do

            scope :ordered, order("`#{table_name}`.`#{_column}` #{_direction.to_s.upcase}")

            before_validation :set_default_order_column_value
            after_save :fix_order_column_after_save

            unless _scope.empty?
              validates _column, presence: true, uniqueness: {scope: _scope}
            else
              validates _column, uniqueness: true
            end
          end
        end

        def sortable?
          @@_sortable_options.is_a? Hash
        end

        def sortable_options
          @@_sortable_options
        end

      end

      module InstanceMethods

        # Wstawia dany obiekt za obiektem +target+. Jeżeli +target+ 
        # nie jest obiektem tej samej klasy, próbuje użyć +target+ jako id 
        # obiektu tej samej klasy
        def put_after(target, force = true)
          column, scope, direction = [
            self.class.sortable_options[:column],
            self.class.sortable_options[:scope],
            self.class.sortable_options[:direction]
          ]

          unless target.is_a? self.class
            target = self.class.find(target)
          end

          scope.each do |c|
            if force
              self.send :"#{c}=", target.send(c)
            elsif self.send(c) == target.send(c)
              self.errors.add(c, :equal_to, count: target.send(c))
              return false
            end
          end

          self.class.transaction do
            torder = target.send(column)
            case direction
            when :asc then 
              objs = self.class
                .where("`#{column}` > ?", torder)
              scope.each do |c|
                objs = objs.where(c => target.send(c))
              end
              objs.update_all("`#{column}` = `#{column}` + 1")
              self.send(:"#{column}=", torder + 1)
            else
              objs = self.class
                .where("`#{column}` >= ?", torder)
              scope.each do |c|
                objs = objs.where(c => target.send(c))
              end
              objs.update_all("`#{column}` = `#{column}` + 1")
              self.send(:"#{column}=", torder)
            end
            self.save!
          end
        rescue  
          false
        end

        def sortable?
          self.class.sortable?
        end

        protected

        # Ustawia domyslną wartość dla columny definującej porządek
        # Wartość jest o jeden większa od ostatniego elementu w scopie 
        # lub 1 dla nowego elementu
        def set_default_order_column_value
            column, scope = [
              self.class.sortable_options[:column],
              self.class.sortable_options[:scope]
            ]

            return unless self.send(column).blank?
            pos = scope.inject(self.class.unscoped.order("#{column} ASC")) do |obj, c|
              obj.where(c => self.send(c))
            end.last.try(column) || 0
            self.send(:"#{column}=", pos + 1)
        end

        # Porządkuje wartości w kolumnie, od 1 do ilości rekordów w danym scopie
        def fix_order_column_after_save
          column, scope = [
            self.class.sortable_options[:column],
            self.class.sortable_options[:scope]
          ]

          obj = scope.inject(self.class.unscoped.order("#{column} ASC")) do |obj, c|
            obj.where(c => self.send(c))
          end

          #First element position, Last element position, Elements count
          fp, lp, count = obj.first.send(column), obj.last.send(column), obj.count

          unless fp == 1 && lp == count
            obj.all.each_with_index do |obj, idx|
              obj.update_column(column, idx+1)
            end
          end
        end

      end
    end
  end
end