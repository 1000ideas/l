module L
  module FormHelper

    def selection_tag(object, name = 'selected', options = {})
      options.merge! class: 'selection', id: "#{name}_#{object.id}"
      check_box_tag "#{name}[]", object.id, false, options 
    end

    def sort_tag(name, type, options = {})
      options = options.reverse_merge({
        class: [],
        name: 'sort',
        title:I18n.t("sort.#{type.to_s}")
      })

      if options[:class].is_a? String
        options[:class] = [options[:class], (type == :asc ? 'up' : 'down')].uniq
      elsif options[:class].is_a? Enumerable
        options[:class].push(type == :asc ? 'up' : 'down').uniq!
      end

      submit_tag "#{name.to_s}_#{type.to_s}", options
    end
  end
end

