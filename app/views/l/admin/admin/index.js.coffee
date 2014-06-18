_content = $("<%=j render('l/partials/activities', activities: @activities) %>")
<% if params.has_key?(:page) %>
$('.activities-list').trigger('append-next-page', _content.filter('ul.activities-list').html())
<% else %>
$('.activities-list').trigger('reload-content', _content.filter('ul.activities-list'))
<% end %>
