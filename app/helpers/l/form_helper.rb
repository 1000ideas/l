module L
  module FormHelper

  def selection_tag(object, name = 'selected', options = {})
    options.merge! class: 'selection', id: "#{name}_#{object.id}"
    check_box_tag "#{name}[]", object.id, false, options 
  end

  end
end

