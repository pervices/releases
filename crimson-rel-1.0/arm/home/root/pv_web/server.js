var express = require('express');
var app     = express();
var favicon = require('serve-favicon');

app.set('view engine', 'jade');
app.use(express.static(__dirname + '/public'));
app.use(favicon(__dirname + '/public/img/favicon.ico'));

app.get('/', function (req, res) {
  res.render('index', {
     title: "Crimson"
  });
});

app.get('/rx', function (req, res) {
  res.render('rx', {
     title: "RX Chain"
  });
});

app.get('/tx', function (req, res) {
  res.render('tx', {
     title: "TX Chain"
  });
});

app.get('/clock', function (req, res) {
  res.render('clock', {
     title: "Clock"
  });
});

app.get('/config', function (req, res) {
  res.render('config', {
     title: "Configuration"
  });
});

app.get('/debug', function (req, res) {
  res.render('debug', {
     title: "Debug"
  });
});

var io = require('socket.io').listen(app.listen(80, function () {
    var host = this.address().address;
    var port = this.address().port;
    console.log('Crimson server listening at http://%s:%s', host, port);
  })
);

var props = require('./prop.js')(io);
