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
    @_fileupload()
    @_init_data_picker()


    $(document).on 'focus blur', '.custom-file-field input:file', (event) ->
      $(event.target).parent().toggleClass('focus', event.type == 'focusin')

    $(document).on 'ajax:complete', 'form', (event) ->
      $('input:file', event.target).val('').change()

    $(document).on 'click', '.small-field > label', (event) ->
      parent = $(event.currentTarget).parent()
      height = parent.prop('scrollHeight')
      if parent.hasClass('open')
        parent.css('max-height', '').removeClass('open')
      else
        parent.css('max-height', "#{height}px").addClass('open')

    $(document).on 'change', '.custom-file-field input[type=file]', (event) ->
      el = $(event.currentTarget)
      value = null
      if el.prop('files')?
        value = $.map $(el.prop('files')), (val, idx) ->
          val.name
        value = value.join(', ')
      else
        value = el.val().replace(/.*fakepath[\\\/]/, '')

      el.closest('.custom-file-field').find('input[type=text][disabled]').val ( value )

    $(document).on 'opened', '[data-dropdown-content]', (event, dropdown, target) ->
      if dropdown.hasClass('axis-right')
        _left = dropdown.position().left + target.outerWidth() - dropdown.outerWidth()
        dropdown.css(left: _left)

    @submenu_hidden_buttons()
    @set_main_content_height()

    $('.items-list, .left-menu ul.root, .old-type-form, .activities-list')
      .perfectScrollbar(includePadding: true)
    @load_on_scroll()

    $(window).on 'resize', (event) =>
      @set_main_content_height()
      @submenu_hidden_buttons()
      $('.ps-container').perfectScrollbar('update')

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

    $(document).on 'reload-content', (event, content) =>
      all_selected = @all_selected()
      element = $(event.target)
      if $(content).children().length > 0
        element.replaceWith $(content)
        $('.items-list').perfectScrollbar(includePadding: true)
        $(document).foundation()
      @load_on_scroll()
      @set_main_content_height()
      if all_selected
        $('.items-list input[type=checkbox]').each (idx, el) ->
          $(el)
            .prop('checked', true)
            .trigger('change', [true])
        @selection_changed()

    $(document).on 'click', '.f-dropdown:not(.content) a', (event) ->
      $(document).foundation('dropdown', 'closeall')

    @_modal_dialog()
    $(document).on 'click', '.admin-modal .modal-content > a.close', (event) =>
      event.preventDefault();
      @close_modal();


    @_sortable_list()
    @selection_changed()

  load_on_scroll: ->
    $('.items-list').on 'scroll', (event) ->
      $element = $(event.target)
      scrollBottom = $element.prop('scrollHeight') - $element.height() - $element.scrollTop()
      $element.find('.show-more a').click() if scrollBottom < 200

  async_file_upload: (id, options = {}) ->
    url = (element = $("##{id}")).data('url')
    default_options = {
      sequentialUploads: true
      singleFileUploads: true
      formData: (form) ->
        $('input[type=hidden]', form)
          .filter (idx, el) ->
            $(el).attr('name').match(/^(utf8|authenticity_token)$/)
          .serializeArray()
      add: (e, data) ->
        queue_id = data.fileInput.data('queue');
        queue = $("##{queue_id}")
        template = queue.data('template')

        if template?
          file = data.files[0];
          template = template.replace("{{name}}", file.name)
          data.context = $(template).appendTo(queue.show())
          data.context
            .find('a.cancel')
            .click (event) ->
              event.preventDefault();
              data.jqXHR.abort();
        data.submit()

      progress: (e, data) ->
        return unless data.context?
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.progress .meter').width("#{progress}%")

      always: (e, data) ->
        return unless data.context?
        data
          .context
          .addClass('done')
          .delay(3000)
          .fadeOut 'slow', ->
            $(this).remove()
            queue_id = data.fileInput.data('queue');
            queue = $("##{queue_id}")
            if queue.children('.queue-item').length == 0
              queue.hide()
    }

    element.fileupload $.extend(default_options, options)


  set_main_content_height: ->
    _height = $(window).innerHeight() - $('header.panel-header').outerHeight() - 2
    $('.main-content').height(_height)
    $('.main-content .items-list, .old-type-form, .activities-list').each (idx, el) ->
      element = $(el)
      _new_height = _height - element.position().top
      element.height(_new_height)

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

  modal: (content, options = {}) ->
    modal = @_modal_dialog()
    modal.find('.modal-content')
      .html(content)
      .append('<a class="close" href="#"></a>')
    modal
      .foundation()
      .addClass('open')
      .find('.scroll-panel')
      .perfectScrollbar(includePadding: true)

  close_modal: ->
    modal = @_modal_dialog()
    if $('.items-list, .no-items').length > 0
      $.ajax
        url: location.href
        dataType: 'script'
    modal.find('[data-tinymce]').each (idx, el) ->
      tinyMCELoader.remove(el.id) if el.id?
    modal.removeClass('open')

  _modal_dialog: ->
    modal = null
    if (modal = $('#form-admin-modal')).length == 0
      modal = $('<div id="form-admin-modal" class="admin-modal"><div class="cover"></div><div class="modal-content"></div></div>').appendTo('body')
    modal

  action_on_selected: (url, options = {}) ->
    console.log("Not used any more")
    return

  _init_data_picker: ->
    _init_each_datepicker = ->
      $('.input-calendar').each ->
        input = $('input[type=text]', this)
        method = input.data('date') ? 'datepicker'
        return if input.hasClass('hasDatepicker')
        button = $('a.button', this)
        input[method]
          showButtonPanel: true
          showOtherMonths: true
        # })
        button.click ->
          input[method]('show')

    $(document)
      .on 'click', '.ui-datepicker, a[data-handler], button[data-handler]', (event) ->
        event.stopPropagation()
        event.preventDefault()
      .ajaxComplete(_init_each_datepicker)

    lang = $('html').attr('lang') ? 'pl'
    $.datepicker.setDefaults($.datepicker.regional[lang]);
    $.datepicker.setDefaults(dateFormat: 'dd/mm/yy');
    $.timepicker.setDefaults($.timepicker.regional[lang]);
    _init_each_datepicker()

  selection_changed: (el) ->
    select_all = $('#selection_all_ids').closest('.custom-check-box')
    if @all_selected()
      select_all.removeClass('unknown').addClass('checked')
    else if @any_selected()
      select_all.removeClass('checked').addClass('unknown')
    else
      select_all.removeClass('checked').removeClass('unknown')

    $('.submenu .selection a').each (idx, el) =>
      data = {ids: @selected()}
      href = $(el).attr('href').split(/[\?&]ids/, 1)[0]
      glue  = if href.indexOf('?') < 0 then '?' else '&'

      $(el).attr('href', "#{href}#{glue}#{$.param(data)}")
    $('.submenu').toggleClass('selected', @any_selected())
    @submenu_hidden_buttons()

  selected: ->
    $('.items-list input[type=checkbox]:checked')
      .map (idx, el) ->
        el.value
      .get()

  unselected: ->
    $('.items-list input[type=checkbox]:not(:checked)')
      .map (idx, el) ->
        el.value
      .get()

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
    group = $('.items-list[data-sortable-update]:not(.filtered)')
      .sortable
        nested: true
        group: 'items'
        handle: 'a[data-sort-handle]'
        containerSelector: 'ul.children'
        onDrop: (item, container, _super) ->
          _super(item, container)
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

    if (element = $('.items-list[data-sortable-update]:not(.filtered)')).length > 0
      element
        .addClass('sortable')
        .perfectScrollbar('update')

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
