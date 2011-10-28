/*
@project VFW Project 1
@author  Ryan Faerman
@term    September 2011
*/

var $ = function(id) {
	return document.getElementById(id);
}

var storage = {
	set: function(k, v) {
		return localStorage.setItem(k, JSON.stringify(v));
	},
	get: function(k) {
		return JSON.parse(localStorage.getItem(k));
	},
	clear: function() {
		return localStorage.clear();
	}
};

var saveData = function(edit) {
	var data = {
		title: $('title').value,
		rating: $('range').value,
		favorite: $('favorite').checked ? 'yes' : 'no',
		pubdate: $('pubdate').value,
		summary: $('summary').value,
		age_group: $('age_group').value,
	};
	
	db = storage.get('db') || [];
	
	console.log(edit);
	
	(edit) ? db[parseInt(edit.replace('edit_', ''))] = data : db.push(data);
	storage.set('db', db);
	
	return data;
};

var form = '';

var getData = function() {
	db = storage.get('db') || [{
		age_group: 'Everyone',
		title: 'Spiderman Unlimited',
		rating: 4,
		favorite: 'yes',
		pubdate: '2011-10-16',
		summary: 'An awesome comic book about spiderman'
	},
	{
		age_group: 'Mature (18+)',
		title: 'Punisher Doomsday',
		rating: 7,
		favorite: 'yes',
		pubdate: '2011-10-14',
		summary: 'An awesome, gory, story about Frank Castle aka The Punishers'
	}];

	var images = {
		'Everyone': 'everyone.png',
		'Teens (< 18)': 'teens.png',
		'Mature (18+)': 'mature.png'
	};

	html = '';
	for(i in db) {
		r = db[i];
		console.log(r.age_group);
		html += '<div class="item"><ul>';
		html += '	<li><img src="assets/img/'+images[r.age_group]+'" /></li>';
		html += '	<li><strong>Title</strong> '+r.title+'</li>';
		html += '	<li><strong>Rating</strong> '+r.rating+'</li>';
		html += '	<li><strong>Favorite</strong> '+r.favorite+'</li>';
		html += '	<li><strong>Published Date</strong> '+r.pubdate+'</li>';
		html += '	<li><strong>Summary</strong> '+r.summary+'</li>';
		html += '	<li><strong>Age Group</strong> '+r.age_group+'</li>';
		html += '	<li class="actions"><button type="button" class="editButton" value="'+i+'">Edit</button> <button type="button" class="deleteButton" value="'+i+'">Delete</button> </li>';
		html += '</ul></div>';
	}
	$('form').innerHTML = html;
	
	editButtons = document.getElementsByClassName('editButton');
	deleteButtons = document.getElementsByClassName('deleteButton');
	for(i=0; i < editButtons.length; i++) {
		editButtons[i].addEventListener('click', function(){
			db = storage.get('db') || [];
			comic = db[this.value];
			
			resetForm();
			
			$('title').value = comic.title;
			$('range').value = comic.range;
			$('favorite').checked = (comic.favorite == 'yes');
			$('pubdate').value = comic.pubdate;
			$('summary').value = comic.summary;			
			
			$('submit').innerHTML = 'Edit Comic Book';
			$('submit').value = 'edit_'+this.value;
		});
	}
	
	for(i=0; i < deleteButtons.length; i++) {
		deleteButtons[i].addEventListener('click', function(){
			db = storage.get('db') || [];
			
			db.splice(this.value, 1);
			storage.set('db', db);
			getData();
			
		
		});
	}
};

var prepareSelect = function(a){
	
	var html = '';
	for(i in a) {
		html += '<option id="'+a[i]+'">'+a[i]+'</option>';
	}
	$('age_group').innerHTML = html;
};

var validate = function() {
	var errors = {
		title: !$('title').value,
		rating: !$('range').value,
		pubdate: !$('pubdate').value,
		summary: !$('summary').value,
		age_group: !$('age_group').value,
	};
	
	passed = true;
	for(i in errors) {
		if(errors[i]) {
			passed = false;
			$(i).className += ' error';
		}
	}
	
	if(!passed) {
		$('errorMsg').style.display = "block";
	}
	
	return passed;
};

var resetForm = function() {
	
	$('form').innerHTML = form;
	
	prepareSelect(["Everyone", "Teens (&lt; 18)", "Mature (18+)"]);
	
	$('submit').addEventListener('click', function(e){
		e.preventDefault();
		
		// validate data
		if(validate()) {
			// pass: alert success
			saveData(this.value);
			alert('Comic Book Saved');
		} 	
	});
	
	$('view_comics').addEventListener('click', function(e){
		e.preventDefault();
		getData();
	});
	
	$('clear_comics').addEventListener('click', function(e){
		e.preventDefault();
		storage.clear();
		window.location = window.location;
	});
};


// DOM Ready
window.addEventListener("DOMContentLoaded", function(){
	form = $('form').innerHTML;
	
	
	resetForm();
	
	
	
	// edit comic
	
	// delete comic
});