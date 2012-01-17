function(doc) {
	emit(doc.age_group, {
		title: doc.title,
		rating: doc.rating,
		pubdate: doc.pubdate,
	});
}