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

class LazyAdmin
  constructor: ->
    @_init_selection()
    @_custom_file_input()
    @_locales_tabs()
    @_fileupload()
    @_init_data_picker()

    $(document).on 'opened', '[data-dropdown-content]', (event, dropdown, target) ->
      if dropdown.hasClass('axis-right')
        _left = dropdown.position().left + target.outerWidth() - dropdown.outerWidth()
        dropdown.css(left: _left)

    @submenu_hidden_buttons()
    @set_main_content_height()

    $('.items-list')
      .on 'jsp-initialised jsp-scroll-y', (event) ->
        window.context_menu && window.context_menu.close_all_context_menus()
        jsp = $(event.target).data('jsp')
        if !jsp? || jsp.isAboutEnd(50)
          $('.show-more a', event.target).click()
        if jsp?
          if (padding = $('.items-list-header').width() - jsp.getContentPane().outerWidth()) > 0
            $('.items-list-header').css('paddingRight': padding)

      .jScrollPane()

    $('.left-menu ul.root').jScrollPane()

    $(window).on 'resize', (event) =>
      @set_main_content_height()
      @submenu_hidden_buttons()

    $(document).on 'click', '.left-menu li.has-submenu > a', (event) ->
      event.preventDefault()
      $(event.currentTarget).parent().toggleClass('opened')

    $(document).on 'append-next-page', (event, content) =>
      all_selected = @all_selected()
      element = $(event.target)
      element.find('.show-more').replaceWith $(content)
      element.foundation()
      @set_main_content_height()
      if all_selected
        $('.items-list input[type=checkbox]').each (idx, el) ->
          $(el)
            .prop('checked', true)
            .trigger('change', [true])
        @selection_changed()


    @_sortable_list()


  set_main_content_height: ->
    _height = $(window).innerHeight() - $('header.panel-header').outerHeight()
    $('.main-content').height(_height)
    menu = $('.left-menu ul.root')
    (mjsp = menu.data('jsp')) && mjsp.reinitialise()
    if (list = $('.main-content .items-list')).length > 0
      _list_height = _height - list.position().top
      list.height(_list_height)
      (jsp = list.data('jsp')) && jsp.reinitialise()

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

  _init_data_picker: ->
    _init_each_datepicker = ->
      $('.input-calendar').each ->
        input = $('input[type=text]', this)
        return if input.hasClass('hasDatepicker')
        button = $('a.button', this)
        input.datepicker()
        button.click ->
          input.datepicker('show')

    $(document)
      .on 'click', '.ui-datepicker, a[data-handler], button[data-handler]', (event) ->
        event.stopPropagation()
        event.preventDefault()
      .ajaxComplete(_init_each_datepicker)

    lang = $('html').attr('lang') ? 'pl'
    $.datepicker.setDefaults($.datepicker.regional[lang]);
    $.datepicker.setDefaults(dateFormat: 'dd/mm/yy');
    _init_each_datepicker()

  selection_changed: (el) ->
    select_all = $('#selection_all_ids').closest('.custom-check-box')
    if @all_selected()
      select_all.removeClass('unknown').addClass('checked')
    else if @any_selected()
      select_all.removeClass('checked').addClass('unknown')
    else
      select_all.removeClass('checked').removeClass('unknown')

  selected: ->
    $('.items-list input[type=checkbox]:checked').map (idx, el) ->
      el.value

  unselected: ->
    $('.items-list input[type=checkbox]:not(:checked)').map (idx, el) ->
      el.value

  all_selected: ->
    @selected().length > 0 and @unselected().length == 0

  any_selected: ->
    @selected().length > 0

  _init_selection: ->
    $(document).on 'change', '.items-list input[type=checkbox]', (event, mute) =>
      el = $(event.currentTarget)
      @selection_changed(el) unless mute == true

    $(document).on 'click', '#selection_all_ids', (event) =>
      event.preventDefault();
      if @any_selected()
        $('.items-list input[type=checkbox]:checked').each (idx, el) ->
          $(el)
            .prop('checked', false)
            .trigger('change', [true])
      else
        $('.items-list input[type=checkbox]').each (idx, el) ->
          $(el)
            .prop('checked', true)
            .trigger('change', [true])
      @selection_changed()

  _sortable_list: ->
    group = $('.items-list[data-sortable-update]:not(.filtered) .jspPane')
      .sortable
        nested: true
        group: 'items'
        handle: 'a[data-sort-handle]'
        # tolerance: -10
        containerSelector: 'ul.children, .jspPane'
        onDrop: (item, container, _super) ->
          _super(item, container)
          if (jsp = group.closest('.jspScrollable').data('jsp'))?
            jsp.reinitialise()

          try
            url = group.closest('[data-sortable-update]').data('sortable-update')
            object = {
              tree: group.sortable('serialize').get(0)
              _method: 'PUT'
            }
            $.ajax
              url: url
              data: object
              type: 'POST'
              dataType: 'script'
            true
          catch error
            false

    $('.items-list[data-sortable-update]:not(.filtered)').addClass('sortable')


  _locales_tabs: ->
    $('.locales-tabs').each ->
      if $(this).children('ul').first().children('li').length == 1
        $(this).children('ul').first().hide()
      else
        $(this).tabs()

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
