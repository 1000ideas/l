errors = <%= @user.errors.full_messages.to_json.html_safe %>
reset_form = <%= params.has_key?(:add_next).to_s %>

if errors.length > 0
  $('.modal-content .notification').text( errors.join(' ') ).slideDown()
else
  $('.notification').slideUp ->
    $(this).text("<%= j flash.discard(:notice) %>").slideDown()
  if reset_form
    $('.modal-content form').param('reset')()
  else
    $('.modal-content form h2').text("<%=j t('l.admin.users.form.title.update') %>")
    $('.modal-content form button[name=save]').text("<%=j t('helpers.submit.user.update') %>")
