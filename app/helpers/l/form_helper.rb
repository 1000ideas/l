module L
  module FormHelper

    def selection_tag(object, name = 'selected', options = {})
      options.merge! class: 'selection', id: "#{name}_#{object.id}"
      check_box_tag "#{name}[]", object.id, false, options 
    end

    def sort_tag(name, type, options = {})
      options.merge!({
        class: (type == :asc ? 'up' : 'down'),
        name: 'sort',
        title:I18n.t("sort.#{type.to_s}")
      })

      submit_tag "#{name.to_s}_#{type.to_s}", options
    end
  end
end

