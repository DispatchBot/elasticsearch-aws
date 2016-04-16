var Elasticsearch = require('elasticsearch'),
  config = require('./config'),
  Promise = require('bluebird');

exports.archive = function(event, context) {

  var es = new Elasticsearch.Client({
    host: config.url,
    log: 'info'
  });

  var now = new Date();
  var minDate = new Date(now.getTime() - (config.num_days_to_keep * 24 * 60 * 60 * 1000));
  console.log('Deleting any indexes less than ', minDate);

  var threshold = [
    'logstash',
    [
      minDate.getFullYear(),
      padNumber(minDate.getMonth() + 1),
      padNumber(minDate.getDate())
    ].join('.')
  ].join('-');

  return es.indices.get({
    index: 'logstash-*'
  }).then(function(indices) {
    var promises = [];
    for (var name in indices) {
      if (name < threshold) {
        console.log('Deleting index ', name);

        promises.push(es.indices.delete({
          index: name
        }).then(function() {
          console.log('Successfully deleted index ', name);
        }));
      }
    }

    return Promise.all(promises).then(function() {
      context.succeed('Success');
    }).catch(function(err) {
      console.error(err);
      context.fail('Failed to archive 1 or more logstash indexes', err);
    });
  });
}

function padNumber(number) {
  if (number < 10) {
    return '0' + number;
  }

  return number;
}
