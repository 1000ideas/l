<% if @news.errors.any? %>
errors = <%= @news.errors.full_messages.to_json.html_safe %>
$('.modal-content .notification').text( errors.join(' ') ).slideDown()
<% else %>
reset_form = <%= params.has_key?(:add_next).to_s %>
$('.notification').slideUp ->
  if reset_form
    $('.modal-content form').each (idx, el) ->
      el.reset()
  else
    lazy.modal "<%= j render('edit_form') %>"
  $('.notification').text("<%= j flash.discard(:notice) %>").slideDown()
<% end %>
