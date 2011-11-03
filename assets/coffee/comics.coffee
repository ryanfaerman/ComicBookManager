$('nav a.menu ').live 'click', (e) ->
	e.preventDefault()
	$('nav .open').removeClass 'open'
	$(this).parent('li').addClass 'open'

$('.sub-menu a').live 'click', (e) ->
	e.preventDefault()


# ## Database Primer
# This has all the example data, to be replaced by the local 
# storage version of the database
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

categories =
	mature: 
		title: "Mature"
		age: "21+"
	adult:
		title: "Adult"
		age: "18+"
	teen:
		title: "Teen"
		age: "18+"
	preteen:
		title: "Pre-Teen"
		age: "18+"
	children:
		title: "Children"
		age: "18+"

category_order = ['children', 'teen', 'preteen', 'adult', 'mature']

# Our little collection of Mustache Templates
templates =

	# The list items for the category
	collection: '''
			<li>
				<a href="#" class="menu">{{category}}</a>
				<ul class="sub-menu">
					{{%IMPLICIT-ITERATOR}}
					{{#comics}}
					<li><a href="#">{{.}}</a></li>
					{{/comics}}
				</ul>
			</li>
	'''

$ ->
	$.each category_order, (i, e) ->
		console.log e

