$(document).ready(function() {
   // bootstrap switches
   $("[name='en']").bootstrapSwitch({
      onText: 'ON',
      offText: 'OFF',
      size: 'mini',
      onColor: 'success'
      //offColor: 'danger'
   });

   $("[name='hi-low']").bootstrapSwitch({
      onText: 'HIGH',
      offText: 'LOW',
      size: 'mini',
      onColor: 'success'
   });
});

// socket.io connection
var socket = io.connect();

// current channel and board/page
var cur_chan = 'a';
var cur_board = 'rx';
var cur_root = 'rx_a';
var pathname = window.location.pathname;

// Switch channel views
// This function will load the current states of the channel onto the page
$("#chan_a,#chan_b,#chan_c,#chan_d").click(function() {
   $(this).parent().parent().children().removeClass('active');
   $(this).parent().attr('class', 'active');

   // update the channel
   var chan = $(this).attr('id');
   if     (chan == 'chan_a') cur_chan = 'a';
   else if(chan == 'chan_b') cur_chan = 'b';
   else if(chan == 'chan_c') cur_chan = 'c';
   else if(chan == 'chan_d') cur_chan = 'd';
   cur_root = cur_board + '_' + cur_chan;

   // load the channel state
   if      (pathname.indexOf('rx') > -1) load_rx();
   else if (pathname.indexOf('tx') > -1) load_tx();
});

// En/disable channel
$("#chan_en").on('switchChange.bootstrapSwitch', function(event, state) {
   socket.emit('prop_wr', { file: cur_root + '/pwr', message: state ? '1' : '0' });
   var is_rx = cur_root.indexOf('rx') > -1;

   // if turn on, overwrite with the current settings
   if (state) {
      $("#loadingModal").modal('show');
      setTimeout(function() {         
         if (is_rx) {
            write_rx();
            activateControls_rx(true);
         } else {
            write_tx();
            activateControls_tx(true);
         }
         $("#loadingModal").modal('hide');
      }, 4000);
   } else {
      if (is_rx)  activateControls_rx(false);
      else        activateControls_tx(false);
   }
});

// En/disable DHCP
$("#dhcp_en").on('switchChange.bootstrapSwitch', function(event, state) {
   socket.emit('prop_wr', { file: 'fpga/link/net/dhcp_en', message: state ? '1' : '0' });
   $("#mgmt_ip").prop('disabled', state);
});

// led
$("#led").click(function() {
   socket.emit('prop_wr', { file: cur_root + '/board/led', message: '5' });
});

// Reset buttons
$("#reset_fpga").click(function() {
   socket.emit('prop_wr', { file: 'fpga/board/restreq', message: '1' });
});

// Send uart command
$("#send_uart_cmd").click(function() {
   var cmd = $("#uart_cmd").val();
   if (cmd) {
      socket.emit('raw_cmd', { message: "echo '" + cmd + "' | mcu" });
   }
});

// pressing enter on uart command redirects a click
$("#uart_cmd").keypress(function(event) {
   if (event.keyCode == 13)
      $("#send_uart_cmd").click();
});

// jesd sync
$("#jesdsync").click( function() {
   socket.emit('prop_wr', { file: 'fpga/board/jesd_sync', message: '1' });
});

// board version
$("#version").click( function() {
   if (cur_board == 'time')
      socket.emit('raw_cmd', { message: "echo 'board -v' | mcu -f s" });
   else if (cur_board == 'fpga')
      socket.emit('raw_cmd', { message: "echo 'board -v' | mcu" });
   else if (cur_board == 'tx')
      socket.emit('raw_cmd', { message: "echo 'board -v' | mcu -f t" });
   else if (cur_board == 'rx')
      socket.emit('raw_cmd', { message: "echo 'board -v' | mcu -f r" });
});

// board temperature
$("#temperature").click(function() {
   if (cur_board == 'time')
      socket.emit('raw_cmd', { message: "echo 'board -t' | mcu -f s" });
   else if (cur_board == 'fpga')
      socket.emit('raw_cmd', { message: "echo 'board -t' | mcu" });
   else if (cur_board == 'tx')
      socket.emit('raw_cmd', { message: "echo 'board -c 15 -t' | mcu -f t" });
   else if (cur_board == 'rx')
      socket.emit('raw_cmd', { message: "echo 'board -c 15 -u' | mcu -f r" });
});

// system reset
$("#reset_system").click(function() {
   socket.emit('prop_wr', { file: 'fpga/board/sys_rstreq', message: '1' });
});

// board channel features
$("#chan_init,#chan_demo,#chan_mute,#chan_reset").click(function() {
   $("#adminModal").modal('show');
});

// board test routines
$("[id$=_test]").click( function() {
   $("#adminModal").modal('show');
});

// board dump routines
$("#hmc_dump").click(function() {
   socket.emit('raw_cmd', { message: "echo 'dump -f' | mcu -f s" });
});

$("#lmk_dump").click(function() {
   socket.emit('raw_cmd', { message: "echo 'dump -c' | mcu -f s" });
});

$("#dac_dump").click(function() {
   socket.emit('raw_cmd', { message: "echo 'dump -c " + cur_chan + " -d' | mcu -f t" });
});

$("#gpiox_dump").click(function() {
   if (cur_board == 'tx')
      socket.emit('raw_cmd', { message: "echo 'dump -c " + cur_chan + " -g' | mcu -f t" });
   else if (cur_board == 'rx')
      socket.emit('raw_cmd', { message: "echo 'dump -c " + cur_chan + " -g' | mcu -f r" });
});

$("#adc_dump").click(function() {
   socket.emit('raw_cmd', { message: "echo 'dump -c " + cur_chan + " -a' | mcu -f r" });
});

$("#adrf_dump").click(function() {
   socket.emit('raw_cmd', { message: "echo 'dump -c " + cur_chan + " -v' | mcu -f r" });
});

// program board
$("#program_start").click(function() {
   var option = $( "#program_board option:selected" ).val();
   //console.log( $('#program_hexfile').prop('files')[0]);
   //socket.emit('hexfile', { board: option, buf: $('#program_hexfile').prop('files')[0] });
});

// gain
$("#gain_range").change(function(){
   $("#gain_display").text($(this).val() + ' dB');
   socket.emit('prop_wr', { file: cur_root + '/rf/gain/val', message: $(this).val() });
});

// i-bias
$("#ibias_range").change(function(){
   $("#ibias_display").text('I: ' + $(this).val() + ' mV');
   socket.emit('prop_wr', { file: cur_root + '/rf/freq/i_bias', message: ($(this).val()/100) });
});

// q-bias
$("#qbias_range").change(function(){
   $("#qbias_display").text('Q: ' + $(this).val() + ' mV');
   socket.emit('prop_wr', { file: cur_root + '/rf/freq/q_bias', message: ($(this).val()/100) });
});

// sample rate
$("#sr_set").click(function(){
   socket.emit('prop_wr', { file: cur_root + '/dsp/rate', message: $("#sr").val()});

   // read the actual values for the sample rate
   setTimeout(function() {
      socket.emit('raw_cmd', { message: "mem rr " + cur_board + cur_chan + "1" });
      socket.emit('raw_cmd', { message: "mem rr " + cur_board + cur_chan + "4" });
   }, 500);
});

// rf band
$("#rf_band").on('switchChange.bootstrapSwitch', function(event, state) {
   socket.emit('prop_wr', { file: cur_root + '/rf/freq/band', message: state ? '1' : '0' });
});

// lna bypass
$("#lna_en").on('switchChange.bootstrapSwitch', function(event, state) {
   socket.emit('prop_wr', { file: cur_root + '/rf/freq/lna', message: state ? '0' : '1' });
});

// dsp signed data
$("#signed").on('switchChange.bootstrapSwitch', function(event, state) {
   socket.emit('prop_wr', { file: cur_root + '/dsp/signed', message: state ? '1' : '0' });
});

// reference clock
$("#ext_ref").on('switchChange.bootstrapSwitch', function(event, state) {
   socket.emit('prop_wr', { file: cur_root + '/source/ref', message: state ? 'external' : 'internal' });
});

// external sync
$("#ext_sync").on('switchChange.bootstrapSwitch', function(event, state) {
   socket.emit('prop_wr', { file: cur_root + '/source/sync', message: state ? 'external' : 'internal' });
});

// external VCO 
$("#ext_vco").on('switchChange.bootstrapSwitch', function(event, state) {
   socket.emit('prop_wr', { file: cur_root + '/source/vco', message: state ? 'external' : 'internal' });
});

// frequency of synthesizer
$("#synth_freq_set").click( function() {
   if (!$("#synth_freq").val()) return;
   socket.emit('prop_wr', { file: cur_root + '/rf/freq/val', message: $("#synth_freq").val() });
   setTimeout( function() {
      socket.emit('prop_rd', { file: cur_root + '/rf/freq/val', debug: true});
   }, 1000);
});

// phase increment
$("#dsp_nco_set").click( function() {
   if (!$("#dsp_nco").val()) return;
   socket.emit('prop_wr', { file: cur_root + '/dsp/nco_adj', message: $("#dsp_nco").val() });
});

// dsp reset
$("#dsp_reset").click( function() {
   socket.emit('prop_wr', { file: cur_root + '/dsp/rstreq', message: '1' });
});

// loopback
$("#loopback").on('switchChange.bootstrapSwitch', function(event, state) {
   socket.emit('prop_wr', { file: cur_root + '/dsp/loopback', message: state ? '1' : '0' });
});

// link settings
$("#link_set").click( function() {
   socket.emit('prop_wr', { file: cur_root + '/link/port',     message: $("#port").val() });
   if (cur_board == 'rx') {
      socket.emit('prop_wr', { file: cur_root + '/link/ip_dest',  message: $("#ip").val() });
      socket.emit('prop_wr', { file: cur_root + '/link/mac_dest', message: $("#mac").val() });
   }
});

// sfp settings
$("#sfpa_set").click( function() {
   socket.emit('prop_wr', { file: 'fpga/link/sfpa/ip_addr', message: $("#sfpa_ip").val() });
   socket.emit('prop_wr', { file: 'fpga/link/sfpa/mac_addr', message: $("#sfpa_mac").val() });
   socket.emit('prop_wr', { file: 'fpga/link/sfpa/pay_len', message: $("#sfpa_paylen").val() });
});

$("#sfpb_set").click( function() {
   socket.emit('prop_wr', { file: 'fpga/link/sfpb/ip_addr', message: $("#sfpb_ip").val() });
   socket.emit('prop_wr', { file: 'fpga/link/sfpb/mac_addr', message: $("#sfpb_mac").val() });
   socket.emit('prop_wr', { file: 'fpga/link/sfpb/pay_len', message: $("#sfpb_paylen").val() });
});

$("#mgmt_set").click( function() {
   socket.emit('prop_wr', { file: 'fpga/link/net/hostname', message: $("#hostname").val() });
   //if (!$('#dhcp_en').bootstrapSwitch('state'))
   socket.emit('prop_wr', { file: 'fpga/link/net/ip_addr', message: $("#mgmt_ip").val() });
});

// dac nco
$("#dac_nco_set").click( function() {
   if (!$("#dac_nco").val()) return;
   socket.emit('prop_wr', { file: cur_root + '/rf/dac/nco', message: $("#dac_nco").val() });
});

// hexfile
$("#program_hexfile").change( function() {
   if( $("#program_hexfile").val())
      $("#program_start").removeClass('disabled');
});

// receive console from server
socket.on('raw_reply', function (data) {
   // if reading back the sample rate
   if (data.cmd == ("mem rr " + cur_board + cur_chan + "1")) {
      val1 = parseInt("0x" + data.message.substring(data.message.length-3, data.message.length-1)) + 1;
      val2 = parseInt("0x" + data.message.substring(data.message.length-5, data.message.length-3)) + 1;
      val = val1 * val2;
      $("#sr_div_display").text("1/" + val);
      if ($("#sr_resamp_display").text() != "")
         $("#sr_display").text((322265625 * 4 / 5 / val));
      else
         $("#sr_display").text((322265625 / val));
      return;
   }

   if (data.cmd == ("mem rr " + cur_board + cur_chan + "4")) {
      val = parseInt(data.message.substring(0, data.message.length-1));
      div = $("#sr_div_display").text();
      div = div.substring(2, div.length);
      if (val >= 0x8000) {
         $("#sr_resamp_display").text("4/5 * ");
         $("#sr_display").text((322265625 * 4 / 5 / parseInt(div)));
      } else {
         $("#sr_resamp_display").text("");
         $("#sr_display").text((322265625 / parseInt(div)));
      }
      return;
   }

   //console.log("Raw reply: " + data.message);
   if ($("#chist")) {
      $("#chist").val( $("#chist").val() + data.cmd + "\n");
      $("#chist").change();
   }

   if ($("#cout")) {
      if (data.message[data.message.length-2] == '>')
         $("#cout" ).val( $("#cout" ).val() + "\n" + data.message.substring(0, data.message.length-3));
      else
         $("#cout" ).val( $("#cout" ).val() + "\n" + data.message.substring(0, data.message.length-1));
      $("#cout").change();
   }
});

// auto scroll-bar
$('#cout,#chist').change(function() {
   $(this).scrollTop($(this)[0].scrollHeight);
});

// receive debug msg from server
socket.on('prop_wr_ret', function (data) {
   //console.log(data.message);
   $("#cout" ).val( $("#cout" ).val() + "\n" + data.message);
   $("#cout").change();
});

// receive data from server
socket.on('prop_ret', function (data) {
   var channel = cur_chan;

   var debug_msg = "Read from " + data.file + ": " + data.message;
   //console.log(debug_msg);
   if (data.debug) {
      $("#cout" ).val( $("#cout" ).val() + "\n" + debug_msg);
      $("#cout").change();
   }

   // Lookup table for return data
   if (data.file == 'fpga/link/sfpa/ip_addr') {
      $('#sfpa_ip').val(data.message);
   } else if (data.file == 'fpga/link/sfpa/mac_addr') {
      $('#sfpa_mac').val(data.message);
   } else if (data.file == 'fpga/link/sfpa/pay_len') {
      $('#sfpa_paylen').val(data.message);
   } else if (data.file == 'fpga/link/sfpb/ip_addr') {
      $('#sfpb_ip').val(data.message);
   } else if (data.file == 'fpga/link/sfpb/mac_addr') {
      $('#sfpb_mac').val(data.message);
   } else if (data.file == 'fpga/link/sfpb/pay_len') {
      $('#sfpb_paylen').val(data.message);
   } else if (data.file == 'fpga/link/net/dhcp_en') {
      $('#dhcp_en').bootstrapSwitch('state', parseInt(data.message) != 0, true);
   } else if (data.file == 'fpga/link/net/hostname') {
      $('#hostname').val(data.message);
   } else if (data.file == 'fpga/link/net/ip_addr') {
      $('#mgmt_ip').val(data.message);
   } else if (data.file == cur_root + '/pwr') {
      $('#chan_en').bootstrapSwitch('state', parseInt(data.message) != 0, true);
      var is_rx = cur_root.indexOf('rx') > -1;

      if (parseInt(data.message) != 0) {
         if (is_rx) activateControls_rx(true);
         else  activateControls_tx(true);
      } else {
         if (is_rx) activateControls_rx(false);
         else  activateControls_tx(false);
      }
   } else if (data.file == cur_root + '/rf/freq/val') {
      $('#synth_freq').val(data.message);
   } else if (data.file == cur_root + '/rf/freq/lna') {
      $('#lna_en').bootstrapSwitch('state', parseInt(data.message) == 0, true);
   } else if (data.file == cur_root + '/rf/gain/val') {
      $('#gain_range').val(parseInt(data.message));
      $("#gain_display").text(parseInt(data.message) + ' dB');
   } else if (data.file == cur_root + '/rf/freq/band') {
      $('#rf_band').bootstrapSwitch('state', parseInt(data.message) != 0, true);
   } else if (data.file == cur_root + '/dsp/signed') {
      $('#signed').bootstrapSwitch('state', parseInt(data.message) != 0, true);
   } else if (data.file == cur_root + '/dsp/nco_adj') {
      $('#dsp_nco').val(data.message);
   } else if (data.file == cur_root + '/link/port') {
      $('#port').val(data.message);
   } else if (data.file == cur_root + '/link/ip_dest') {
      $('#ip').val(data.message);
   } else if (data.file == cur_root + '/link/mac_dest') {
      $('#mac').val(data.message);
   } else if (data.file == cur_root + '/dsp/rate') {
      $('#sr').val(data.message);

      // read the actual values for the sample rate
      setTimeout(function() {
         socket.emit('raw_cmd', { message: "mem rr " + cur_board + cur_chan + "1" });
         socket.emit('raw_cmd', { message: "mem rr " + cur_board + cur_chan + "4" });
      }, 500);
   } else if (data.file == cur_root + '/rf/freq/i_bias') {
      $('#ibias_range').val(parseInt(data.message)*100);
      $("#ibias_display").text('I: ' + parseInt(data.message)*100 + ' mV');
   } else if (data.file == cur_root + '/rf/freq/q_bias') {
      $('#qbias_range').val(parseInt(data.message)*100);
      $("#qbias_display").text('I: ' + parseInt(data.message)*100 + ' mV');
   } else if (data.file == cur_root + '/rf/dac/nco') {
      $('#dac_nco').val(data.message);
   } else if (data.file == cur_root + '/dsp/loopback') {
      $('#loopback').bootstrapSwitch('state', parseInt(data.message) != 0, true);
   } else if (data.file == cur_root + '/source/ref') {
      $('#ext_ref').bootstrapSwitch('state', data.message.indexOf('external') > -1, true);
   } else if (data.file == cur_root + '/source/sync') {
      $('#ext_sync').bootstrapSwitch('state', data.message.indexOf('external') > -1, true);
   } else if (data.file == cur_root + '/source/vco') {
      $('#ext_vco').bootstrapSwitch('state', data.message.indexOf('external') > -1, true);
   }

});

// en/disable the configurations
function activateControls_rx(state) {
   //$('#rf_band').bootstrapSwitch('readonly', !state);
   //$('#lna_en').bootstrapSwitch('readonly', !state);
   $("#synth_freq").prop('disabled', !state);
   $("#synth_freq_set").prop('disabled', !state);
   $("#gain_range").prop('disabled', !state);
   $("#dsp_reset").prop('disabled', !state);
   //$('#signed').bootstrapSwitch('readonly', !state);
   $("#dsp_nco").prop('disabled', !state);
   $("#dsp_nco_set").prop('disabled', !state);
   $("#sr").prop('disabled', !state);
   $("#sr_set").prop('disabled', !state);
   $("#ip").prop('disabled', !state);
   $("#link_set").prop('disabled', !state);
   $("#mac").prop('disabled', !state);
   $("#port").prop('disabled', !state);
   //$('#loopback').bootstrapSwitch('readonly', !state);
}

function activateControls_tx(state) {
   //$('#rf_band').bootstrapSwitch('readonly', !state);
   $("#synth_freq").prop('disabled', !state);
   $("#synth_freq_set").prop('disabled', !state);
   $("#dac_nco").prop('disabled', !state);
   $("#dac_nco_set").prop('disabled', !state);
   $("#ibias_range").prop('disabled', !state);
   $("#qbias_range").prop('disabled', !state);
   $("#gain_range").prop('disabled', !state);
   $("#dsp_reset").prop('disabled', !state);
   $("#dsp_nco").prop('disabled', !state);
   $("#dsp_nco_set").prop('disabled', !state);
   $("#sr").prop('disabled', !state);
   $("#sr_set").prop('disabled', !state);
   $("#link_set").prop('disabled', !state);
   $("#port").prop('disabled', !state);
}

// write the current settings to SDR
function write_rx() {
   socket.emit('prop_wr', { file: cur_root + '/rf/freq/val'   , message: $('#synth_freq').val()});
   socket.emit('prop_wr', { file: cur_root + '/rf/freq/lna'   , message: $('#lna_en').bootstrapSwitch('state') ? '0' : '1'});
   socket.emit('prop_wr', { file: cur_root + '/rf/freq/band'  , message: $('#rf_band').bootstrapSwitch('state') ? '1' : '0'});
   socket.emit('prop_wr', { file: cur_root + '/rf/gain/val'   , message: $('#gain_range').val()});
   socket.emit('prop_wr', { file: cur_root + '/dsp/signed'    , message: $('#signed').bootstrapSwitch('state') ? '1' : '0'});
   socket.emit('prop_wr', { file: cur_root + '/dsp/nco_adj'   , message: $('#dsp_nco').val()});
   socket.emit('prop_wr', { file: cur_root + '/dsp/rate'      , message: $('#sr').val()});
   socket.emit('prop_wr', { file: cur_root + '/link/port'     , message: $('#port').val()});
   socket.emit('prop_wr', { file: cur_root + '/link/ip_dest'  , message: $('#ip').val()});
   socket.emit('prop_wr', { file: cur_root + '/link/mac_dest' , message: $('#mac').val()});
   socket.emit('prop_wr', { file: cur_root + '/dsp/loopback'  , message: $('#loopback').bootstrapSwitch('state') ? '1' : '0'});
}

function write_tx() {
   socket.emit('prop_wr', { file: cur_root + '/rf/freq/val'   , message: $('#synth_freq').val()});
   socket.emit('prop_wr', { file: cur_root + '/rf/freq/i_bias', message: $('#ibias_range').val()/100});
   socket.emit('prop_wr', { file: cur_root + '/rf/freq/q_bias', message: $('#qbias_range').val()/100});
   socket.emit('prop_wr', { file: cur_root + '/rf/freq/band'  , message: $('#rf_band').bootstrapSwitch('state') ? '1' : '0'});
   socket.emit('prop_wr', { file: cur_root + '/rf/gain/val'   , message: $('#gain_range').val()});
   socket.emit('prop_wr', { file: cur_root + '/rf/dac/nco'    , message: $('#dac_nco').val()});
   socket.emit('prop_wr', { file: cur_root + '/dsp/nco_adj'   , message: $('#dsp_nco').val()});
   socket.emit('prop_wr', { file: cur_root + '/dsp/rate'      , message: $('#sr').val()});
   socket.emit('prop_wr', { file: cur_root + '/link/port'     , message: $('#port').val()});
}

// Loading config data
function load_config (isLoad) {
   socket.emit('prop_rd', { file: 'fpga/link/sfpa/ip_addr'    ,debug: isLoad});
   socket.emit('prop_rd', { file: 'fpga/link/sfpa/mac_addr'   ,debug: isLoad});
   socket.emit('prop_rd', { file: 'fpga/link/sfpa/pay_len'    ,debug: isLoad});
   socket.emit('prop_rd', { file: 'fpga/link/sfpb/ip_addr'    ,debug: isLoad});
   socket.emit('prop_rd', { file: 'fpga/link/sfpb/mac_addr'   ,debug: isLoad});
   socket.emit('prop_rd', { file: 'fpga/link/sfpb/pay_len'    ,debug: isLoad});
   socket.emit('prop_rd', { file: 'fpga/link/net/dhcp_en'     ,debug: isLoad});
   socket.emit('prop_rd', { file: 'fpga/link/net/hostname'    ,debug: isLoad});
   socket.emit('prop_rd', { file: 'fpga/link/net/ip_addr'     ,debug: isLoad});
}

function load_rx (isLoad) {
   socket.emit('prop_rd', { file: cur_root + '/rf/freq/val'   ,debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/rf/freq/lna'   ,debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/rf/freq/band'  ,debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/rf/gain/val'   ,debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/dsp/signed'    ,debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/dsp/nco_adj'   ,debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/dsp/rate'      ,debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/dsp/loopback'  ,debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/link/port'     ,debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/link/ip_dest'  ,debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/link/mac_dest' ,debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/pwr'           ,debug: isLoad});
}

function load_tx (isLoad) {
   socket.emit('prop_rd', { file: cur_root + '/rf/freq/val'   ,debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/rf/freq/i_bias',debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/rf/freq/q_bias',debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/rf/freq/band'  ,debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/rf/gain/val'   ,debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/rf/dac/nco'    ,debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/dsp/nco_adj'   ,debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/dsp/rate'      ,debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/link/port'     ,debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/pwr'           ,debug: isLoad});
}

function load_clock (isLoad) {
   socket.emit('prop_rd', { file: cur_root + '/source/vco'    ,debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/source/sync'   ,debug: isLoad});
   socket.emit('prop_rd', { file: cur_root + '/source/ref'    ,debug: isLoad});
}

// determine which page is currently loaded
window.onload = function() {
   var loadFunc;
   var refreshFunc;
   if (pathname.indexOf('config') > -1) {
      cur_board = 'fpga';
      cur_root = cur_board;
      loadFunc = load_config;
   } else if (pathname.indexOf('clock') > -1) {
      cur_board = 'time';
      cur_root = cur_board;
      loadFunc = load_clock;
   } else if (pathname.indexOf('debug') > -1) {
      cur_board = 'fpga';
      cur_root = cur_board;
      //loadFunc = load_debug;
   } else if (pathname.indexOf('rx') > -1) {
      cur_board = 'rx';
      cur_root = cur_board + '_' + cur_chan;
      loadFunc = load_rx;
   } else if (pathname.indexOf('tx') > -1) {
      cur_board = 'tx';
      cur_root = cur_board + '_' + cur_chan;
      loadFunc = load_tx;
   }

   loadFunc(true);
   //var refreshID = setInterval(loadFunc, 3000);
}
