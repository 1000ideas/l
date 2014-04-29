class Loader
  @show: ->
    @_instance().show()
  @hide: ->
    @_instance().hide()
  @_instance: ->
    unless @__instance
      @__instance = new Loader()
    @__instance
  constructor: ->
    @loader = $('body > div#lazy-loader')
    if @loader.length == 0
      @loader = $('<div>')
        .attr('id', 'lazy-loader')
        .css(display: 'none')
        .appendTo 'body'
  show: ->
    @loader.fadeIn()
  hide: ->
    @loader.fadeOut()


class Sortable
  constructor: (options = {})->
    return if $('ul.items-list.sortable').length == 0

    url = '' + $('ul.items-list.sortable').first().data('url')

    if url.length == 0
      throw "Element ul.sortable must have data-url."

    if url.indexOf(':id') < 0 || url.indexOf(':target_id') < 0
      throw "Url '#{url}' has to have :id and :target_id placeholders."

    $("ul.items-list.sortable li:not(.header)").draggable appendTo: 'body',
      revert: 'invalid',
      cursor: 'move',
      cancel: '[data-context-button]'

    $("ul.items-list.sortable li:not(.header)").droppable hoverClass: 'ui-state-hover',
      greedy: true,
      drop: (event, ui) ->

        object = $(ui.draggable)
        id = object.find('input[type=checkbox]').val()

        target = $(this)
        target_id = target.find('input[type=checkbox]').val()

        action_url = url
          .replace(':id', id)
          .replace(':target_id', target_id)

        Loader.show()

        $.post(action_url, (data) ->
          object.insertAfter(target)
        )
        .fail( (jqXHR, textStatus) ->
          text = if jqXHR.responseJSON?
            jqXHR.responseJSON.join('. ')
          else
            "Network error"

          $('#notice')
            .html(text)
            .show()
          setTimeout ->
            $('#notice').fadeOut(3000);
          , 3000
        )
        .always( ->
          object.css(top: '', left: '')
          Loader.hide()
        )

class LazyAdmin
  constructor: ->
    @_sortable_list()
    @_selection_actions()
    # @_custom_select()
    @_custom_file_input()
    @_locales_tabs()
    @_fileupload()

    $(document).on 'opened', '[data-dropdown-content]', (event, dropdown, target) ->
      if dropdown.hasClass('axis-right')
        _left = dropdown.position().left + target.outerWidth() - dropdown.outerWidth()
        dropdown.css(left: _left)

    $('.items-list')
      .jScrollPane(autoReinitialise: true)
      .on 'jsp-initialised jsp-scroll-x', (event) ->
        jsp = $(event.target).data('jsp')
        if jsp.getContentHeight() > jsp.getContentPane().height()
          console.log('load data')

    $(window).on 'resize', (event) =>
      @set_main_content_height()
      @submenu_hidden_buttons()
    @submenu_hidden_buttons()
    @set_main_content_height()

    $(document).on 'click', '.left-menu li.has-submenu > a', (event) ->
      event.preventDefault()
      $(event.currentTarget).parent().toggleClass('opened')

  set_main_content_height: ->
    _height = $(window).innerHeight() - $('header.panel-header').outerHeight()
    $('.main-content').height(_height)
    if (list = $('.main-content .items-list')).length > 0
      _list_height = _height - list.position().top
      list.height(_list_height)

  submenu_hidden_buttons: ->
    $('.submenu + ul[data-dropdown-content] li')
      .detach()
      .appendTo('.submenu')

    elements = $('.submenu li:not(.show-more)')
      .filter (idx) ->
        $(this).position().top > 0
      .detach()
      .appendTo('.submenu + ul[data-dropdown-content]')

    $('.submenu li.show-more').toggle(elements.length > 0)



  loader: ->
    Loader

  action_on_selected: (url, options = {}) ->
    console.log("Not used any more")
    return

  _selection_actions: ->
    $('form select#selection_action').on 'change', (event) ->
      ids = []
      for obj in $(this.form).serializeArray()
        if obj.name == 'selection[ids][]'
          ids.push obj.value
      if ids.length > 0 and $(this).val().length > 0
        $(this.form).submit()
      else
        $(this).val('')

  _sortable_list: ->
    @_sortable = new Sortable()

  _locales_tabs: ->
    $('.tabs_container').each ->
      if $(this).children('ul').first().children('li').length == 1
        $(this).children('ul').first().hide()
      else
        $(this).tabs()

  # _custom_select: ->
  #   $('select').customSelect();

  _custom_file_input: ->
    $("input[type=file].custom-file-input.fileupload").customFileInput({path: false});
    $("input[type=file].custom-file-input").customFileInput();

  _fileupload: ->
    if Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0
      $("input[type=file].fileupload").each ->
        $(this).prop('multiple', false)


    $("input[type=file].fileupload").fileupload sequentialUploads: true,
      singleFileUploads: true,
      add: (e, data) ->
        queue = data.fileInput.data('queue');

        if queue
          file = data.files[0];

          remove = $('<a>')
            .attr('href', '#')
            .html('&times;')
            .addClass('close')
            .click (event) ->
              event.preventDefault();
              data.jqXHR.abort();

          name = $('<p>').html file.name

          progress = $('<div>')
            .addClass('progress')
            .progressbar();

          context = data.context = $('<div>')
            .append( remove )
            .append( name )
            .append( progress )
            .addClass('queue-item')
            .appendTo "##{queue}"

        data.submit()
      , progress: (e, data) ->

        if data.context
          progress = parseInt(data.loaded / data.total * 100, 10)
          data.context
            .find('.progress')
            .progressbar 'value', progress
      , always: (e, data) ->
        if data.context
          setTimeout( ->
            data.context
              .fadeOut('slow', ->
                $(this).remove()
              )
          , 3000)

jQuery ->
  window.lazy = new LazyAdmin()
