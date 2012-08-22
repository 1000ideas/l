var LazyAdmin = {
  setup: function() {

    LazyAdmin.form_tabs_init();
    LazyAdmin.form_customization_init();


  },
  destroy_selected: function(selector, controller) {
    LazyAdmin.action_on_selected(selector, controller, null, 'delete');
  },
  action_on_selected: function(selector, controller, action, _method) {
    if (_method == undefined) {
      method = "get";
      _method = "get"
    }
    var ids = $(selector).filter(':checked').map(function() { return $(this).val() });
    ids.each(function() {
      var _url = controller +'/' + this;
      if (action != null) _url += '/' + action;
      _url += '.js';
      if (_method != "get") {
        method = "post";
      }

      $.ajax({ 
        url: _url,
        dataType: "script",
        type: method,
        data: {
          _method: _method
        }
      });
    });
  },
  form_tabs_init: function() {
    $('.tabs_container').tabs();

    //jezeli jest tylko jedna zakladka, to nie wyswietlamy ul,
    //bo nie ma sensu (szczegolnie przy wersjach jezykowych)
    $('.tabs_container ul').each(function(){
        if ($(this).children('li').length == 1) {
            $(this).css("display", "none");
        }
    });
  },
  form_customization_init: function() {
    $('form select').each(function(){
        $(this).addClass('custom');
    });

    $('form select.custom').livequery(function() {
        LazyAdmin.customize_select(this);
    });

    $('div.custom_select select').live('change', function() {
        LazyAdmin.reload_custom_select_span(this);
    });
  },
  customize_select: function(obj) { 
    $(obj).wrap('<div class="custom_select" />');
    $('<span class="custom_select_title"></span>').insertBefore(obj);
    LazyAdmin.reload_custom_select_span(obj);
  },
  reload_custom_select_span: function(obj) {
    var txt = $(obj).children(":selected").text();
    $(obj).prev('span.custom_select_title').text(txt);
  }

}

$(LazyAdmin.setup);
