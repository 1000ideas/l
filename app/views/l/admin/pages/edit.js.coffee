lazy.modal "<%=j render('edit_form') %>"
<%@page.translations.each_with_index do |tran, i| %>
content = $('<div/>').html("<%= tran.content %>").text()
tinymce.get('page_translations_attributes_'+<%=i%>+'_content').setContent(content, {format : 'raw'})	
<%end%>