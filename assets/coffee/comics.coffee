$('nav a.menu ').live 'click', (e) ->
	e.preventDefault()
	$('nav .open').removeClass 'open'
	$(this).parent('li').addClass 'open'

$('.sub-menu a').live 'click', (e) ->
	e.preventDefault()