$ ->

	now = new Date()
	today = now.getFullYear() + "-" + (now.getMonth() + 1) + "-" + now.getDate()
	$("#pubdate").val today

	$('form').submit (e) ->
		e.preventDefault()
		console.log 'hello'
		unless $(this).find('#title').val()
			$(this).find('#title').parents('.clearfix').addClass 'error'
		else 
			$(this).find('#title').parents('.clearfix').removeClass 'error'
			
			if confirm "Your Comic was Saved!\nWould you like to add another?"
				$(this)[0].reset()
			else
				history.back()