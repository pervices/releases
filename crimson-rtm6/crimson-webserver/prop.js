var fs = require('fs');
var state_dir = '/var/volatile/crimson/state/';
var sys = require('util');
var exec = require('child_process').exec;

module.exports = function(io) {
   io.sockets.on('connection', function (socket) {
      // Handle property reads
      socket.on('prop_rd', function (data) {
         var file = data.file;
         var debug = data.debug;

         // read the data from fs
         fs.readFile( state_dir + data.file, 'utf8', function(err, data){
            if (err) console.log("File Read error: ",state_dir ); //throw err;
            // send the data back to the client
            io.sockets.emit('prop_ret', {file: file, message: data, debug: debug});
	    // DEBUG/DEV: To run locally, comment out the above line, and uncomment the line below.
            //io.sockets.emit('prop_ret', {file: file, message: '1', debug: debug}); 
         }); 
      });

      // Handle property updates
      socket.on('prop_wr', function (data) {
         // write to file
         fs.writeFile( state_dir + data.file, data.message , function(err, fd){
            if (err) console.log("File open error", state_dir + data.file); //throw err;
         });

         // send the data back to the client
         var debug_msg = 'Wrote to ' + data.file + ': ' + data.message;
         io.sockets.emit('prop_wr_ret', {message: debug_msg});
         //console.log(debug_msg);
      });
      
      // Send raw commands from the root instead of the state directory
      socket.on('systctl', function (data) {
         state_dir = ''; //change state directory to send commands to the channel control folder
         exec(data.message, function(err, stdout, stderr) {
            if (err) console.log("CMD error:", stdout,stderr); //throw err;
            io.sockets.emit('raw_reply', {cmd: data.message, message: stdout});
            console.log('Raw cmd: ' + data.message);
         });
      });


      // Handle raw system cmds
      socket.on('raw_cmd', function (data) {
         exec(data.message, function(err, stdout, stderr) {
            if (err) console.log("CMD error:", stdout,stderr); //throw err;
            io.sockets.emit('raw_reply', {cmd: data.message, message: stdout});
            console.log('Raw cmd: ' + data.message);
         });
      });

      // handle hex-files for programming
      socket.on('hexfile', function (data) {
         console.log('/lib/mcu/vaunt-' + data.board + '.hex');
         fs.writeFile( '/lib/mcu/vaunt-' + data.board + '.hex', data.buf, function(err) {
            if (err) throw err;
            console.log("Sent hexfile to server!");

            exec("/lib/mcu/flash w " + data.board + " crimson", function(err, stdout, stderr) {
               if (err) throw err;
               io.sockets.emit('raw_reply', {cmd: data.message, message: stdout});
               console.log('Raw cmd: ' + data.message);
            });
         });
      });

   });
}
