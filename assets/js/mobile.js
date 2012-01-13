(function() {
  var Comic, dataSource, storage;
  window.COMICS_DB = '_comics_db_';
  window.DEBUG = true;
  window.CATEGORIES = {
    children: 'Children',
    preteen: 'Pre-Teen',
    teen: 'Teens',
    adult: 'Adult',
    mature: 'Mature'
  };
  window.storage = storage = {
    set: function(k, v) {
      return localStorage.setItem(k, JSON.stringify(v));
    },
    get: function(k) {
      return JSON.parse(localStorage.getItem(k));
    },
    push: function(k, v) {
      var stack;
      stack = this.get(k) || [];
      stack.push(v);
      this.set(k, stack);
      if (window.DEBUG) {
        console.log("Pushed " + v + " onto " + k);
      }
      return stack;
    },
    pop: function(k) {
      var item, stack;
      stack = this.get(k) || [];
      if (stack.length !== 0) {
        item = stack.pop();
        this.set(k, stack);
        if (window.DEBUG) {
          console.log("Popped " + item + " from " + k);
        }
        return item;
      } else {
        if (window.DEBUG) {
          console.log("" + k + " is empty");
        }
        return false;
      }
    },
    clear: function() {
      return localStorage.clear();
    }
  };
  window.dataSource = dataSource = {
    csv: function(path, cb) {
      var fields, output;
      output = [];
      fields = [];
      return $.get(path, function(d) {
        $.each(d.split("\n"), function(i, line) {
          return $.each(line.split(','), function(j, col) {
            var col_name;
            if (i === 0) {
              return fields[j] = col.trim().toLowerCase();
            } else {
              if (j === 0) {
                output[i] = {};
              }
              col_name = fields[j];
              return output[i][col_name] = col.trim();
            }
          });
        });
        output.shift();
        if (cb) {
          return cb(output);
        }
      });
    },
    json: function(path, cb) {
      return $.get(path, function(d) {
        if (cb) {
          return cb(d);
        }
      }, 'json');
    },
    xml: function(path, cb) {
      var output;
      output = [];
      return $.get(path, function(xml) {
        $(xml).find('item').each(function(i, item) {
          return output[i] = {
            title: $(item).find('title').text(),
            rating: $(item).find('rating').text(),
            pubdate: $(item).find('pubdate').text(),
            age_group: $(item).find('age_group').text()
          };
        });
        if (cb) {
          return cb(output);
        }
      }, 'xml');
    },
    load: function(path, cb) {
      var fileType;
      fileType = path.split('.').pop();
      return this[fileType](path, cb);
    }
  };
  window.Comic = Comic = function() {
    return {
      save: function() {
        storage.push(window.COMICS_DB + this.age_group, this);
        return $.event.trigger('comic_saved', this);
      }
    };
  };
  $(function() {
    var now, today;
    setTimeout(function() {
      return $.event.trigger('comic_saved');
    }, 100);
    now = new Date();
    today = now.getFullYear() + "-" + (now.getMonth() + 1) + "-" + now.getDate();
    $("#pubdate").val(today);
    $('form#add-comic button[type=submit]').bind('click', function(e) {
      var $form;
      $form = $(this).parents('form');
      if (!$form.find('#title').val()) {
        e.preventDefault();
        return $form.find('#title').parents('.clearfix').addClass('error');
      } else {
        $form.find('.error').removeClass('error');
        return console.log('no error');
      }
    });
    return $('form#add-comic').submit(function(e) {
      var comic, data;
      comic = new Comic;
      data = {
        title: $(this).find('#title').val(),
        rating: $(this).find('#range').val(),
        favorite: $(this).find('#checkbox-0').is(':checked'),
        pubdate: $(this).find('#pubdate').val(),
        summary: $(this).find('#summary').val(),
        age_group: $(this).find('#age_group').val()
      };
      $.extend(comic, data);
      comic.save();
      $(this)[0].reset();
      if (!confirm("Your Comic was Saved!\nWould you like to add another?")) {
        history.back();
      } else {
        $.mobile.silentScroll(0);
      }
      return false;
    });
  });
  $('#collection').bind('comic_saved', function() {
    var collection;
    collection = '';
    $.each(window.CATEGORIES, function(age_group, group_name) {
      var comics, section;
      comics = storage.get(window.COMICS_DB + age_group);
      console.log(comics);
      section = "<li class='" + age_group + "'><a>" + group_name + "</a>";
      section += '<ul data-theme="">';
      if (comics) {
        $.each(comics, function(i, comic) {
          return section += "<li><a href='#comic' id='" + i + "' class='comic' rel='" + age_group + "'>" + comic.title + "</a></li>";
        });
      }
      section += '</ul></li>';
      return collection += section;
    });
    return $(this).html(collection).listview('refresh');
  });
  $('a.comic').live('click', function(e) {
    var comic, comics;
    comics = storage.get(window.COMICS_DB + $(this).attr('rel'));
    comic = comics[$(this).attr('id')];
    storage.set('now_viewing', {
      db: window.COMICS_DB + $(this).attr('rel'),
      id: $(this).attr('id')
    });
    $('#comic').find('h2, h1').text(comic.title);
    return $('#comic').find('div.summary').text(comic.summary);
  });
  $('a.load').live('click', function(e) {
    dataSource.load($(this).attr('href'), function(data) {
      console.log(data);
      $.each(data, function(i, record) {
        var comic;
        comic = new Comic;
        $.extend(comic, record);
        return comic.save();
      });
      return $.mobile.changePage('#list');
    });
    e.preventDefault();
    return false;
  });
  $('a#purge-storage').live('click', function(e) {
    console.log('hello!');
    storage.clear();
    return $.event.trigger('comic_saved');
  });
  $('#comic').live('pageinit', function(e) {
    return console.log(e);
  });
}).call(this);
