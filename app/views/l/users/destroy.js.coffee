try
  $("input:checkbox[value=<%= @user.id %>]")
    .parents('li')
    .first()
    .slideUp ->
      $(this).remove()
catch e
  if window.console? and window.console.log?
    console.log( e )

