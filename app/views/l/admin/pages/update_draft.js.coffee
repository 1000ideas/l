lazy.modal "<%=j render('edit_draft_form') %>"
<% if @page.errors.any? %>
errors = <%= @page.errors.full_messages.to_json.html_safe %>
$('.modal-content .notification').text( errors.join(' ') ).slideDown()
<% else %>
$('.notification').slideUp ->
  <% if flash.discard(:notice) %>
  $('.notification').text("<%= j flash.discard(:notice) %>").slideDown()
  <%end%>
  <%if I18n.available_locales.length > 1 %>
  <%@page.translations.each_with_index do |tran, i| %>
  content = $('<div/>').html("<%= tran.content %>").text()
  tinymce.get('page_draft_translations_attributes_'+<%=i%>+'_content').setContent(content, {format : 'raw'})	
  <%end%>
  content = $('<div/>').html("<%= @page.content %>").text()
  tinymce.get('l_page_draft_content').setContent(content, {format : 'raw'})
  <%else%>
  <%end%>
<%end%>