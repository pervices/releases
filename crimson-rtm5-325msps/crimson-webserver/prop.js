var fs = require('fs');
var state_dir = '/var/crimson/state/';
var sys = require('sys');
var exec = require('child_process').exec;

module.exports = function(io) {
   io.sockets.on('connection', function (socket) {
      // Handle property reads
      socket.on('prop_rd', function (data) {
         var file = data.file;
         var debug = data.debug;

         // read the data from fs
         fs.readFile( state_dir + data.file, 'utf8', function(err, data){
            if (err) throw err;

            // send the data back to the client
            io.sockets.emit('prop_ret', {file: file, message: data, debug: debug});
         }); 
      });

      // Handle property updates
      socket.on('prop_wr', function (data) {
         // write to file
         fs.writeFile( state_dir + data.file, data.message , function(err, fd){
            if (err) throw err;
         });

         // send the data back to the client
         var debug_msg = 'Wrote to ' + data.file + ': ' + data.message;
         io.sockets.emit('prop_wr_ret', {message: debug_msg});
         //console.log(debug_msg);
      });


      // Handle raw system cmds
      socket.on('raw_cmd', function (data) {
         exec(data.message, function(err, stdout, stderr) {
            if (err) throw err;
            io.sockets.emit('raw_reply', {cmd: data.message, message: stdout});
            console.log('Raw cmd: ' + data.message);
         });
      });

      // handle hex-files for programming
      socket.on('hexfile', function (data) {
         console.log('/home/root/pv_mcu/' + data.board + '.hex');
         fs.writeFile( '/home/root/pv_mcu/' + data.board + '.hex', data.buf, function(err) {
            if (err) throw err;
            console.log("Sent hexfile to server!");

            exec("/home/root/pv_mcu/flash.sh " + data.board, function(err, stdout, stderr) {
               if (err) throw err;
               io.sockets.emit('raw_reply', {cmd: data.message, message: stdout});
               console.log('Raw cmd: ' + data.message);
            });
         });
      });

   });
}
