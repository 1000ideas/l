class CustomFileInput
  constructor: (@element, options = {}) ->
    return if @element.custom_file_input

    $element = $(@element)
    $element.wrap $('<div>').addClass('custom-file-input')

    @parent = $element.parent()
    @parent.addClass(@element.className)


    label = $element.data('label') || 'Select file'

    @button = $('<span>')
      .addClass("file-button")
      .text(label)
      .appendTo( @parent )
    
    unless options.path
      @show_path = true
    else
      @show_path = options.path

    @_setup_events_handlers()

    @element.custom_file_input = this
  
  _get_filename: ->
    if @element.files
      @element.files[0].name
    else
      $(@element).val().replace(/^.*fakepath[\\\/]/, '')

  _set_path: ->
    value = @_get_filename()

    if value.length > 0
      @parent.attr('title', value)
    else
      @parent.attr('title', '')

  _setup_events_handlers: ->
    self = this

    $(@element)
      .bind 'change', (event) ->
        self._set_path() if self.show_path

jQuery.fn.customFileInput = (options = {}) ->
  this.each ->
    new CustomFileInput(this, options)
  this
