errors = <%= @user.errors.full_messages.to_json.html_safe %>
reset_form = <%= @reset_form.to_s %>

if errors.length > 0
  $('.modal-content .notification').text( errors.join(' ') ).slideDown()
else
  $('.notification').slideUp ->
    if reset_form
      $('.modal-content form').each (idx, el) ->
        el.reset()
    else
      lazy.modal "<%= j render('form') %>"
    $('.notification').text("<%= j flash.discard(:notice) %>").slideDown()

