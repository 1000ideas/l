lazy.modal "<%=j render('edit_draft_form') %>"
content = $('<div/>').html("<%= @page.content %>").text()
tinymce.activeEditor.setContent(content, {format : 'raw'})