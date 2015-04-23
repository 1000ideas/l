errors = <%%= @<%= singular_table_name %>.errors.full_messages.to_json.html_safe %>

if errors.length > 0
  $('.notification').slideUp ->
    $('.modal-content .notification').text( errors.join(' ') ).slideDown()
else
  $('.notification').slideUp ->
    $('.notification').text("<%%= j flash.discard(:notice) %>").slideDown()


