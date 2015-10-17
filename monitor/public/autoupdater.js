var intervalTimer = setInterval(function(){
    autoupdater.look_up()
}, 1000)


var autoupdater = {
  look_up: function() {
    {
      $.ajax("/auto_update", {
        data: { "query":"wibble" }
      }).done(function(data) {
//        console.log("Hello "+data[0]['name']+" "+data[0]['lastseen']);

        if(data.length > 0) {
          node_list.clear();
          for(var i=0; i<data.length; i++) {
              node_list.add(data[i]);
          };
          node_list.render();
        }
      }).fail(function() {
        console.log("AJAX fail:", arguments);
      });
    }
  }
};


autoupdater.look_up();
