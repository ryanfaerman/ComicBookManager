window.COMICS_DB = '_comics_db_'
window.DEBUG = yes

window.storage = storage = 
	set: (k, v) ->
		localStorage.setItem(k, JSON.stringify(v))
	get: (k) -> 
		JSON.parse(localStorage.getItem(k))
	push: (k, v) ->
		stack = this.get(k) || []

		stack.push v
		this.set k, stack

		if window.DEBUG then console.log "Pushed #{v} onto #{k}"
		return stack
	pop: (k) ->
		stack = this.get(k) || []

		unless stack.length is 0
			item = stack.pop()
			this.set k, stack

			if window.DEBUG then console.log "Popped #{item} from #{k}"
			return item
		else
			if window.DEBUG then console.log "#{k} is empty"
			return false
	clear: -> 
		localStorage.clear()

$ ->
	now = new Date()
	today = now.getFullYear() + "-" + (now.getMonth() + 1) + "-" + now.getDate()
	$("#pubdate").val today


	$('form#add-comic button[type=submit]').bind 'click', (e) ->
		$form = $(this).parents('form')
		unless $form.find('#title').val()
			e.preventDefault()
			$form.find('#title').parents('.clearfix').addClass 'error'
		else
			$form.find('.error').removeClass 'error'
			console.log 'no error'
	
	$('form#add-comic').submit (e) ->

		data =
			title: $(this).find('#title').val()
			rating: $(this).find('#range').val()
			favorite: $(this).find('#checkbox-0').is(':checked')
			pubdate: $(this).find('#pubdate').val()
			summary: $(this).find('#summary').val()
			age_group: $(this).find('#age_group').val()
		
		storage.push window.COMICS_DB+data.age_group, data

		$(this)[0].reset()
		unless confirm "Your Comic was Saved!\nWould you like to add another?"
			history.back()
		else
			$.mobile.silentScroll(0);
		return false


		

