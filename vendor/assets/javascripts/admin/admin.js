var LazyAdmin = {
  setup: function() {

    LazyAdmin.form_tabs_init();
    LazyAdmin.form_customization_init();
    LazyAdmin.form_upload_init();

    if (typeof(LazyAdmin.extension_setup) == "function") LazyAdmin.extension_setup();


  },
  destroy_selected: function(selector, controller) {
    LazyAdmin.action_on_selected(selector, controller, null, 'delete');
  },
  perform_member_action: function(controller, action, id, data) {
    url = '/' + controller + '/' + id;
    if (action != null) url += '/' + action;
    data = $.extend( {
      _method: 'get'
    }, data);
    type = 'get';
    if (data._method != 'get') type = 'post';
    dataType = data.dataType;
    data.dataType = undefined;
    $.ajax({
      url: url,
      dataType: dataType,
      type: type,
      data: data
    });
  },
  perform_collection_action: function(controller, action, data) {
    url = '/' + controller;
    if (action != null) url += '/' + action;
    data = $.extend( {
      _method: 'get'
    }, data);
    type = 'get';
    if (data._method != 'get') type = 'post';
    dataType = data.dataType;
    data.dataType = undefined;
    $.ajax({
      url: url,
      dataType: dataType,
      type: type,
      data: data
    });
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

    setInterval(function(){
      $('form select.custom:not(.customized)').map(function() {
          LazyAdmin.customize_select(this);
          $(this).addClass('customized');
      });
    }, 100);

    $(document).on('change', 'div.custom_select select', function() {
        LazyAdmin.reload_custom_select_span(this);
    });
  },
  customize_select: function(obj) { 
    $(obj).wrap('<div class="custom_select" />');
    $('<span class="custom_select_title"></span>').insertBefore(obj);
    LazyAdmin.reload_custom_select_span(obj);
  },
  reload_custom_select_span: function(obj) {
    var txt = $(obj).find("option:selected").text();
    $(obj).prev('span.custom_select_title').text(txt);
  },
  form_upload_init: function() {
    var placeholder = null, form_data = {}, csrf_token = '', csrf_param = '',
      script_path = '', session_key = '', queue_id = '';
    placeholder = $('#upload_photo');

    script_path = placeholder.data('path');
    queue_id = placeholder.find('.queue').attr('id');
    session_key = placeholder.data('cookie-session-key');
    session_value = placeholder.data('cookie-session-value'); 
    form_data[session_key] = session_value;

    csrf_token = $('meta[name=csrf-token]').attr('content');
    csrf_param = $('meta[name=csrf-param]').attr('content');
    form_data[csrf_param] = encodeURI(csrf_token);

    $("#upload_photo .button").uploadify({
      swf: '/assets/uploadify.swf',
      uploader: script_path,
      queueID: queue_id,
      buttonText: 'Wybierz pliki',
      formData: form_data,
      onUploadSuccess: function(file, data) {
        try {
          eval(data);
        } catch (ex) {
          console.log(ex);
        }
      }
    });

  }

}

$(LazyAdmin.setup);
