$('nav a.menu ').live 'click', (e) ->
	e.preventDefault()
	$('nav .open').removeClass 'open'
	$(this).parent('li').addClass 'open'

$('.sub-menu a').live 'click', (e) ->
	e.preventDefault()

$ ->
	$('a.back').click (e) ->
		e.preventDefault()
		history.back()

	$('form#add').submit (e) ->
		e.preventDefault()
		console.log 'hello'
		unless $(this).find('#title').val()
			$(this).find('#title').parents('.clearfix').addClass 'error'
		else 
			$(this).find('#title').parents('.clearfix').removeClass 'error'
			
			alert "Your Comic was Saved!"
			$(this)[0].reset()