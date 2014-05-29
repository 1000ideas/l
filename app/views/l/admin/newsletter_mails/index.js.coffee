_content = $("<%=j render('list') %>")
<% if params.has_key?(:page) %>
$('.items-list').trigger('append-next-page', _content.find('ul.items-list').html())
<% else %>
$('.items-list, .no-items').trigger('reload-content', _content.find('ul.items-list'))
<% end %>
