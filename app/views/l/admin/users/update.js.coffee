errors = <%= @user.errors.full_messages.to_json.html_safe %>
reset_form = <%= @reset_form.to_s %>

if errors.length > 0
  $('.modal-content .notification').text( errors.join(' ') ).slideDown()
else
  $('.notification').slideUp ->
    if reset_form
      lazy.modal "<%= j render('form', user: User.new) %>"
    $('.notification').text("<%= j flash.discard(:notice) %>").slideDown()

