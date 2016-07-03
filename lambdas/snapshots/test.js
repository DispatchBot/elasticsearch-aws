var snapper = require('./snapshot');

var event = {};
var context = {
  succeed: function(msg) {
    console.log(msg);
  },
  fail: function(msg) {
    console.error(msg);
  }
};

snapper.snapshot(event, context).then(function() {
  process.exit();
});
