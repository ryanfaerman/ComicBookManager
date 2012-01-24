window.COMICS_DB = '_comics_db_'
window.COUCH_DB = 'comicbookmanager'
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

$ ->
	$categories = $(@).find '#collection'
	$categories.empty()

	$.each window.CATEGORIES, (age_group, category_name) ->
		$categories.append """
			<li class="#{age_group}"><a href="category.html?category=#{age_group}">#{category_name}</a></li>
		"""
	$categories.listview 'refresh'

urlData = (url) ->
	url = $($.mobile.activePage).data 'url'
	getData = url.split('?').pop()

	output = {}

	$.each getData.split('&'), (i, data) ->
		bits = data.split '='
		k = decodeURIComponent(bits[0])
		v = decodeURIComponent(bits[1])
		output[k] = v
	
	output

$('#category').live 'pageshow', ->
	category = urlData()['category']
	$(@).find('h1').html window.CATEGORIES[category]
	$category_list = $(@).find '#category-list'
	$category_list.empty()

	$.couch.db('comicbookmanager').view "comicbookmanager/by_category", key: category, success: (data) ->
		$.each data.rows, (i, comic) ->
			console.log comic
			$category_list.append """
				<li><a href="comic.html?id=#{comic.id}">#{comic.value.title}</a></li>
			"""
		$category_list.listview 'refresh'



