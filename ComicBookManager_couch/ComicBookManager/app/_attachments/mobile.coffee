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
			$category_list.append """
				<li><a href="comic.html?id=#{comic.id}">#{comic.value.title}</a></li>
			"""
		$category_list.listview 'refresh'

$('#comic').live 'pageshow', ->
	_id = urlData()['id']
	$comic = $(@)
	$.couch.db('comicbookmanager').openDoc _id, success: (comic) ->
		$comic.find('h1').html comic.title
		$comic.find('#edit').attr 'href', "form.html?id=#{comic._id}"
		$comic.find('h2').html "#{comic.title} (#{comic.rating} / 10)"
		$comic.find('#age_group').html "Age Group: #{window.CATEGORIES[comic.age_group]}"
		$comic.find('#pubdate').html "Published: #{comic.pubdate}" if comic.pubdate
		$comic.find('#summary').html "#{comic.summary}" if comic.summary

$('#form').live 'pageshow', ->
	_id = urlData()['id']

	now = new Date()
	today = now.getFullYear() + "-" + (now.getMonth() + 1) + "-" + now.getDate()

	if _id
		# edit mode
		$(@).find('a#delete').show()
		$form = $(@).find('form')
		$.couch.db('comicbookmanager').openDoc _id, success: (comic) ->
			console.log comic
			$form.find('#_id').val comic._id
			$form.find('#_rev').val comic._rev
			$form.find('#title').val comic.title
			$form.find('#range').val comic.rating
			$form.find('#pubdate').val comic.pubdate
			$form.find('#summary').val comic.summary if comic.summary

			$form.find("#age_group option[value=#{comic.age_group}").attr 'selected', 'selected'
	else
		# add mode
		$(@).find("#pubdate").val today
		$(@).find('a#delete').hide()

	$(@).find('form#add-comic button[type=submit]').bind 'click', (e) ->
		$form = $(@).parents('form')
		unless $form.find('#title').val()
			e.preventDefault()
			$form.find('#title').parents('.clearfix').addClass 'error'
		else
			$form.find('.error').removeClass 'error'
	
	$(@).find('a#delete').bind 'click', (e) ->
		console.log 'delete clicked!'
		if confirm "Deleting is Permanent and cannot be undone, still delete?"
			console.log 'doDelete'
			toRemove = 
				_id: $('#_id').val()
				_rev: $('#_rev').val()
			$.couch.db('comicbookmanager').removeDoc toRemove, success: (data) ->
				console.log data
				alert "Comic Deleted"
				$.mobile.changePage 'index.html', reverse: true
		else
			console.log 'nope'

	
	$(@).find('form#add-comic').submit (e) ->
		data =
			title: $(@).find('#title').val()
			rating: $(@).find('#range').val()
			pubdate: $(@).find('#pubdate').val()
			summary: $(@).find('#summary').val()
			age_group: $(@).find('#age_group').val()
		console.log data
		if $(@).find('#_id').val() then data._id = $(@).find('#_id').val()
		if $(@).find('#_rev').val() then _rev = $(@).find('#_rev').val()
		

		$.couch.db('comicbookmanager').saveDoc data, 
		success: (data) ->
			rev = data.rev.split('-').shift()
			console.log rev
			if rev > 1
				console.log 'updated!'
				alert "Comic Updated!"				
				
			else
			alert "Comic Saved!"
			$.mobile.changePage 'index.html', reverse: true
			$(@)[0].reset()
		error: (data) ->
			console.log data
		
			


