lazy.modal "<%=j render('edit_draft_form') %>"
<% if @page.errors.any? %>
errors = <%= @page.errors.full_messages.to_json.html_safe %>
$('.modal-content .notification').text( errors.join(' ') ).slideDown()
<% else %>
$('.notification').slideUp ->
  $('.notification').text("<%= j flash.discard(:notice) %>").slideDown()
  <%@page.translations.each_with_index do |tran, i| %>
  content = $('<div/>').html("<%= tran.content %>").text()
  tinymce.get('page_draft_translations_attributes_'+<%=i%>+'_content').setContent(content, {format : 'raw'})	
  <%end%>
<% end %>

