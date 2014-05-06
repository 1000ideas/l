class ContextMenu
  @position: (x, y, w, h, from_mouse, dir) ->
    position = {}
    ww = window.innerWidth
    wh = window.innerHeight

    if x + w > ww or !from_mouse
      dir.left = true
      position.left = x - w
    else
      dir.right = true
      position.left = x

    if y + h > wh and y - h > 0 #and from_mouse
      dir.up = true
      position.top = y - h
    else
      dir.down = true
      position.top = y

    position


  close_all_context_menus: ->
    $('[data-context-holder]')
      .trigger('context:close')
      .remove()

    $('[data-context-button].opened')
      .removeClass('opened')
    true

  open_context_menu_for: (element, x, y, from_mouse = true) ->

    if $(element).data('context-ajax')?
      $.ajax
        url: $(element).data('context-ajax')
        data: '_'
        type: 'POST'
        beforeSend: (jqXHR, settings) ->
          $(element).trigger('before:context:ajax', [jqXHR, settings, from_mouse])
        success: (data) ->
          $(data)
            .openContextMenu(x, y, from_mouse)
    else
      $(element)
        .find('[data-context-target]')
        .clone()
        .openContextMenu(x, y, from_mouse)

  constructor: ->
    $.fn.openContextMenu = (x, y, from_mouse = true) ->
      el = this
        .first()
        .attr('data-context-holder', true)
        .appendTo(document.body)
        .show()

      directions = {up: false, down: false, left: false, right: false}
      position = ContextMenu.position(x, y, el.outerWidth(), el.height(), from_mouse, directions)

      el
        .toggleClass('dir-up', directions.up)
        .toggleClass('dir-down', directions.down)
        .toggleClass('dir-left', directions.left)
        .toggleClass('dir-right', directions.right)
        .toggleClass('from-mouse', from_mouse)
        .toggleClass('from-button', !from_mouse)
        .css(position)
        .trigger('context:open', [directions])

    $(document).on 'contextmenu', '[data-context]', (event) =>
      event.preventDefault()
      return if $(event.target).closest('[data-context-target]').length > 0

      @close_all_context_menus()
      @open_context_menu_for(event.currentTarget, event.pageX,  event.pageY)
      event.stopPropagation();

    $(document).on 'context:open', (event, directions) =>
      el = $('[data-context-button].opened')
        .toggleClass('dir-up', directions.up)
        .toggleClass('dir-down', directions.down)
        .toggleClass('dir-left', directions.left)
        .toggleClass('dir-right', directions.right)

    $(document).on 'click', (event) =>
      @close_all_context_menus()

    $(document).on 'click', '[data-context-holder] a', (event) =>
      @close_all_context_menus()

    # $(window).on 'blur', =>
    #   @close_all_context_menus()

    $(document).on 'click', 'a[data-context-button]', (event) =>
      event.preventDefault()
      event.stopPropagation();
      button = $(event.currentTarget)
      opened = button.hasClass('opened')

      @close_all_context_menus()
      unless opened
        el = button.closest('[data-context]')
        offset = button.offset()
        button.addClass('opened')
        @open_context_menu_for(el, offset.left, offset.top, false)
      false

jQuery -> ( window.context_menu = new ContextMenu() )
