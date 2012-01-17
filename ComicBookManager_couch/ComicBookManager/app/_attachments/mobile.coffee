window.COMICS_DB = '_comics_db_'
window.DEBUG = yes
window.CATEGORIES =
	children: 'Children'
	preteen: 'Pre-Teen'
	teen: 'Teens'
	adult: 'Adult'
	mature: 'Mature'

# A basic storage engine
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

# Data File Importer
window.dataSource = dataSource =
	# this is the most rudimentary of the three parsers
	# try anything fancy, and it'll probably break
	csv: (path, cb) ->
		output = []
		fields = []
		$.get path, (d) ->
			$.each d.split("\n"), (i, line) ->
				$.each line.split(','), (j, col) ->
					if i is 0
						# normalize the fields to lowercase
						# no real reason, I just like them that way
						fields[j] = col.trim().toLowerCase()
					else
						if j is 0 then output[i] = {}
						col_name = fields[j]
						output[i][col_name] = col.trim()
			
			# some cruft ends up in the first field
			output.shift()
			if cb then cb(output)
	# JSON parser exists only for completeness
	json: (path, cb) ->
		$.get path, (d) ->
			if cb then cb(d)
		, 'json'
	xml: (path, cb) ->
		output = []
		$.get path, (xml) ->
			$(xml).find('item').each (i, item) ->
				output[i] = 
					title:		$(item).find('title').text()
					rating: 	$(item).find('rating').text()
					pubdate:	$(item).find('pubdate').text()
					age_group:	$(item).find('age_group').text()

					
			if cb then cb(output)					
		, 'xml'
	load: (path, cb) ->
		fileType = path.split('.').pop()
		this[fileType](path, cb)
					
				


# A wannabe model
window.Comic = Comic = ->
	save: ->
		storage.push window.COMICS_DB + this.age_group, this
		$.event.trigger 'comic_saved', this

$ ->
	setTimeout ->
		$.event.trigger 'comic_saved'
	, 100

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
		comic = new Comic
		data =
			title: $(this).find('#title').val()
			rating: $(this).find('#range').val()
			favorite: $(this).find('#checkbox-0').is(':checked')
			pubdate: $(this).find('#pubdate').val()
			summary: $(this).find('#summary').val()
			age_group: $(this).find('#age_group').val()
		
		$.extend comic, data
		
		comic.save()



		$(this)[0].reset()
		unless confirm "Your Comic was Saved!\nWould you like to add another?"
			history.back()
		else
			$.mobile.silentScroll(0);
		return false
	
$('#collection').bind 'comic_saved', ->
	collection = ''
	$(this).html('')

	refreshListviewTick = no
	refreshCollection = ->
		clearTimeout refreshListviewTick
		refreshListviewTick = setTimeout ->
			$('#collection').listview 'refresh'
		, 500
	
	$.each window.CATEGORIES, (age_group, group_name) ->
		$.get "_view/by_category?key=\"#{age_group}\"", (category) ->
			comics = category.rows
			
			section = "<li class='#{age_group}'><a>#{group_name}</a>"
			section += '<ul data-theme="">'
			if comics.length > 0
				$.each comics, (i, comic) ->
					section += "<li><a href='#comic' id='#{comic.id}' class='comic' rel='#{age_group}'>#{comic.value.title}</a></li>"
			section += '</ul></li>'

			$('#collection').append(section)
			refreshCollection()
		, 'json'



$('a.comic').live 'click', (e) ->
	comics = storage.get window.COMICS_DB + $(this).attr('rel')
	comic = comics[$(this).attr('id')]

	storage.set 'now_viewing', db: window.COMICS_DB + $(this).attr('rel'), id: $(this).attr('id')

	$('#comic').find('h2, h1').text(comic.title)
	$('#comic').find('div.summary').text(comic.summary)

$('a.load').live 'click', (e) ->
	dataSource.load $(this).attr('href'), (data) ->
		console.log data
		$.each data, (i, record) ->
			comic = new Comic
			$.extend comic, record
			comic.save()

		$.mobile.changePage '#list'
	e.preventDefault()
	return false

$('a#purge-storage').live 'click', (e) ->
	console.log 'hello!'
	storage.clear()
	$.event.trigger 'comic_saved'

$('#comic').live 'pageinit', (e) ->
	console.log e	

$('#refresh_couch').live 'click', (e) ->
	$.event.trigger 'comic_saved'
	alert 'it worked!'
	return false




