# encoding: utf-8
module L::Concerns
	module Filtering
		extend ActiveSupport::Concern

    module ClassMethods
      # Filtruj obiekty klasy względem podanych ograniczeń.
      def filter(filters = {})
        filters ||= {}
        filters.inject(self) do |memo, (key, value)|
          filter_name = :"filter_by_#{key}"
          if value.blank?
            memo
          elsif memo.respond_to?(filter_name)
            output = memo.send(filter_name, value)
            if output.is_a?(ActiveRecord::Relation)
              output
            else
              memo.where(id: output.map(&:id))
            end
          else
            ::Rails.logger.error "[filter] Setup #{filter_name} scope for #{name} class!"
            memo
          end
        end
      end
    end
	end
end
