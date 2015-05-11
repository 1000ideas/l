lazy.modal "<%=j render('edit_form') %>"
<% if @gallery.errors.any? %>
errors = <%= @gallery.errors.full_messages.to_json.html_safe %>
$('.modal-content .notification').text( errors.join(' ') ).slideDown()
<% else %>
<% if flash.discard(:notice) %>
$('.notification').text("<%= j flash.discard(:notice) %>").slideDown()
<%end%>
<%end%>

<%if I18n.available_locales.length > 1 %>
<%@gallery.translations.each_with_index do |tran, i| %>
content = $('<div/>').html("<%= tran.content %>").text()
tinymce.get('gallery_translations_attributes_'+<%=i%>+'_content').setContent(content, {format : 'raw'})	
<%end%>
<%else%>
content = $('<div/>').html("<%= @gallery.content %>").text()
tinymce.get('l_gallery_content').setContent(content, {format : 'raw'})	
<%end%>