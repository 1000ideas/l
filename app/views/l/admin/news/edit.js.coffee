lazy.modal "<%= j render('edit_form') %>"
content = $('<div/>').html("<%= @news.content %>").text()
tinymce.activeEditor.setContent(content, {format : 'raw'})