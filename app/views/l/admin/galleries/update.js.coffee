<% if @gallery.errors.any? %>
errors = <%= @gallery.errors.full_messages.to_json.html_safe %>
$('.modal-content .notification').text( errors.join(' ') ).slideDown()
<% else %>
$('.notification').slideUp ->
  $('.notification').text("<%= j flash.discard(:notice) %>").slideDown()
<% end %>
