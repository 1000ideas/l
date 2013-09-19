try
  $("input:checkbox[value=<%= @news.id %>]")
    .parents('li')
    .first()
    .slideUp ->
      $(this).remove()
catch e
  if window.console? and window.console.log?
    console.log( e )
  else
    alert(ex.message)

