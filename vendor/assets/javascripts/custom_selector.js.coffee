class CustomSelector
  constructor: (@element, options = {}) ->
    return if @element.custom_select

    options = $.extend({
        class_name: 'custom-selector'
      }, options)
    return if @element.tagName != 'SELECT'
    @wrapper = $('<div>').addClass(options.class_name).addClass('custom-selector')
    $(@element).wrap @wrapper
    @wrapper = $(@element).parent()
    @label = $('<span>')
    $(@element).before(@label).addClass 'customized'

    @_set_label()
    @_set_up_events()

    @element.custom_select = this

  _set_up_events: ->
    self = this

    $(@element).on 'change keydown', (event) ->
      self._set_label()

    $(@element).focus ->
      self.wrapper.addClass 'focus'

    $(@element).blur ->
      self.wrapper.removeClass 'focus'


  _set_label: ->
    el = $(@element).children(':selected')
    @label.text el.text();
    if el.attr('value').length == 0
      @wrapper.addClass 'placeholder'
    else
      @wrapper.removeClass 'placeholder'


jQuery.fn.customSelect = (options = {}) ->
  $(this).map (idx, el) ->
    selector = new CustomSelector(el, options)
    el
