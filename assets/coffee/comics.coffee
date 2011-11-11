


# An object of the example data, to be replaced by the 
# local storage version of the database
comics =
	mature: [
		{title: "Punisher: Road to Remember"}
		{title: "Punisher: Never Forget"}
		{title: "Punisher: Traveling Salesman"}
		{title: "Iron Man: Armor Wars 1"}
		{title: "Iron Man: Armor Wars 2"}
		{title: "Iron Man: Armor Wars 3"}
		{title: "Iron Man: Armor Wars 4"}
		{title: "Iron Man: Armor Wars 5"}
	]
	adult: [
		{title: "Spiderman 2020: Mary Jane"}
		{title: "Spiderman 2020: Doc Ock"}
		{title: "The Submariner: Origins 1"}
		{title: "The Submariner: Origins 2"}
		{title: "The Submariner: Origins 3"}
	]
	teen: [
		{title: "Spiderman &amp; Friends: Scorpion"}
		{title: "Star Trek: Deep Space Nine #12"}
		{title: "Astro Boy #24"}
	]
	preteen: [
		{title: "Batman &amp; Superman #17"}
		{title: "Justice League: The Titans"}
	]
	children: [
		{title: "Sponge Bob #439"}
		{title: "Dora the Explorer #14"}
	]

# Conversion of the category keys to text
categories =
	mature: 
		title: "Mature"
		age: "21+"
	adult:
		title: "Adult"
		age: "18+"
	teen:
		title: "Teens"
		age: "13-18"
	preteen:
		title: "Pre-Teen"
		age: "9-12"
	children:
		title: "Children"
		age: ""

# From first to last
category_order = ['children', 'teen', 'preteen', 'adult', 'mature']

# Our little collection of Mustache Templates
templates =
	# The list items for the category
	collection: '''
		<li>
			<a href="#{{key}}" class="menu">{{#category}}{{title}} <span>{{age}}</span>{{/category}}</a>
			<ul class="sub-menu">
				{{#comics}}
				<li><a href="#">{{title}}</a></li>
				{{/comics}}
			</ul>
		</li>
	'''
	# List of items in the category
	category: '''
		<li><a href="#{{category}}/{{key}}">{{title}}</a></li>
	'''
	# the back button
	back: '''
		<li><a href="#{{key}}">&larr; {{category}}</a></li>
	'''

$menu = $('nav ul.menu');

manager =
	show:
		collection: ->
			$menu.html ''
			$.each category_order, (i, e) ->
				data = 
					key: e
					category: categories[e]
					comics: comics[e]

				html = Mustache.to_html templates.collection, data
				$menu.append html
		category: (c)->
			$menu.html ''

			data = 
				key: c
				category: categories[c]
			html = Mustache.to_html templates.back, data
			$menu.append html

			$.each comics[c], (i,e) ->
				data =
					key: i
					category: c
					title: e.title
				
				html = Mustache.to_html templates.category, data
				$menu.append html



$ ->
	manager.show.collection()

$('nav a.menu ').live 'click', (e) ->
	e.preventDefault()
	$('nav .open').removeClass 'open'
	$(this).parent('li').addClass 'open'

$('.sub-menu a').live 'click', (e) ->
	e.preventDefault()

