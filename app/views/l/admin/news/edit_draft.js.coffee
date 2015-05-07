lazy.modal "<%=j render('edit_draft_form') %>"
<% if @news.errors.any? %>
errors = <%= @page.errors.full_messages.to_json.html_safe %>
$('.modal-content .notification').text( errors.join(' ') ).slideDown()
<% else %>
<% if flash.discard(:notice) %>
$('.notification').text("<%= j flash.discard(:notice) %>").slideDown()
<%end%>
<%@news.translations.each_with_index do |tran, i| %>
content = $('<div/>').html("<%= tran.content %>").text()
tinymce.get('news_draft_translations_attributes_'+<%=i%>+'_content').setContent(content, {format : 'raw'})	
<%end%>
<% end %>