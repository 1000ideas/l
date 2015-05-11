lazy.modal "<%=j render('edit_form') %>"
<% if @news.errors.any? %>
errors = <%= @news.errors.full_messages.to_json.html_safe %>
$('.modal-content .notification').text( errors.join(' ') ).slideDown()
<% else %>
<% if flash.discard(:notice) %>
$('.notification').text("<%= j flash.discard(:notice) %>").slideDown()
<%end%>
<%end%>

<%if I18n.available_locales.length > 1 %>
<%@news.translations.each_with_index do |tran, i| %>
content = $('<div/>').html("<%= tran.content %>").text()
tinymce.get('news_translations_attributes_'+<%=i%>+'_content').setContent(content, {format : 'raw'})	
<%end%>
<%else%>
content = $('<div/>').html("<%= @news.content %>").text()
tinymce.get('l_news_content').setContent(content, {format : 'raw'})	
<%end%>