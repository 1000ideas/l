<% if params.has_key?(:page) %>
_content = $("<%=j render('list') %>")
$('.items-list').trigger('append-next-page', _content.find('ul.items-list').html())
<% end %>
