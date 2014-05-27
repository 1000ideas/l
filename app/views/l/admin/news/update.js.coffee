<% if @news.errors.any? %>
errors = <%= @news.errors.full_messages.to_json.html_safe %>
$('.modal-content .notification').text( errors.join(' ') ).slideDown()
<% else %>
$('.notification').slideUp ->
  lazy.modal "<%= j render('edit_form') %>"
  $('.notification').text("<%= j flash.discard(:notice) %>").slideDown()
<% end %>
