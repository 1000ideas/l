<% if @news.errors.any? %>
errors = <%= @news.errors.full_messages.to_json.html_safe %>
$('.modal-content .notification').text( errors.join(' ') ).slideDown()
<% else %>
$('.notification').slideUp ->
  $('.notification').text("<%= j flash.discard(:notice) %>").slideDown()
  lazy.modal "<%=j render('edit_form') %>"
  content = $('<div/>').html("<%= @news.content %>").text()
  tinymce.activeEditor.setContent(content, {format : 'raw'})
<% end %>
