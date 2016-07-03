var Elasticsearch = require('elasticsearch'),
  config = require('./config');

exports.snapshot = function(event, context) {

  var es = new Elasticsearch.Client({
    host: config.url,
    log: 'info'
  });

  var now = new Date();
  var snapshot = ['snapshot',
   now.getFullYear(),
   padNumber(now.getMonth() + 1),
   padNumber(now.getDate()),
   padNumber(now.getHours())
 ].join('-');

  console.log('Creating snapshot: ' + snapshot);
  return es.snapshot.create({
    repository: config.repository,
    snapshot: snapshot,
    waitForCompletion: false
  }).then(function() {
    context.succeed('Snapshot created');
  }).catch(function(err) {
    console.error(err);
    context.fail('Snapshot failed');
  });
}

function padNumber(number) {
  if (number < 10) {
    return '0' + number;
  }

  return number;
}
