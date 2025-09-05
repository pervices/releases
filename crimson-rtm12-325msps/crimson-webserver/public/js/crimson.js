$(document).ready(function() {
	// bootstrap switches
	$("[name='en']").bootstrapSwitch({
		onText : 'ON',
		offText : 'OFF',
		size : 'mini',
		onColor : 'success'
	// offColor: 'danger'
	});

	$("[name='hi-low']").bootstrapSwitch({
		onText : 'HIGH',
		offText : 'LOW',
		size : 'mini',
		onColor : 'success'
	});
});

// socket.io connection
var socket = io.connect();

// teza operation mode
var op_mode;

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
	if (chan == 'chan_a')
		cur_chan = 'a';
	else if (chan == 'chan_b')
		cur_chan = 'b';
	else if (chan == 'chan_c')
		cur_chan = 'c';
	else if (chan == 'chan_d')
		cur_chan = 'd';
	cur_root = cur_board + '_' + cur_chan;

	// load the channel state
	if (pathname.indexOf('rx') > -1)
		load_rx();
	else if (pathname.indexOf('tx') > -1)
		load_tx();
});

// En/disable channel
$("#chan_en").on('switchChange.bootstrapSwitch', function(event, state) {
	socket.emit('prop_wr', {
		file : cur_root + '/pwr',
		message : state ? '1' : '0'
	});
	var is_rx = cur_root.indexOf('rx') > -1;
	if (is_rx) {
	   socket.emit('prop_wr', { file: cur_root + '/stream', message: state ? '1' : '0' });
	}
	if (state) {
		socket.emit('prop_wr', {	// select low band
			file: cur_root + '/rf/freq/band',
			message: 0
		});
		socket.emit('raw_cmd', {
			message : "mem rw res_rw3 0x000c0000 0x000c0000",
			debug : false
		});
	} else {	// Commented out as to remove any contention between RX/TX // Once ON, always ON
//		socket.emit('raw_cmd', {
//			message : "mem rw res_rw3 0x00000000 0x000c0000",
//			debug : false
//		});
	}

	// if turn on, overwrite with the current settings
	if (state) {
		$("#loadingModal").modal('show');
		setTimeout(function() {
			if (is_rx) {
				activateControls_rx(true);
				write_rx();
			} else {
				activateControls_tx(true);
				write_tx();
			}
			$("#loadingModal").modal('hide');
		}, 4000);
	} else {
		if (is_rx)
			activateControls_rx(false);
		else
			activateControls_tx(false);
	}
});

// En/disable DHCP
$("#dhcp_en").on('switchChange.bootstrapSwitch', function(event, state) {
	socket.emit('prop_wr', {
		file : 'fpga/link/net/dhcp_en',
		message : state ? '1' : '0'
	});
	$("#mgmt_ip").prop('disabled', state);
});

// En/disable Automatic Gain Control
$("#agc").on('switchChange.bootstrapSwitch', function(event, state) {
	if (state) {
		// socket.emit('raw_cmd', { message: "mem rw res_rw0 0x0 0x1", debug:
		// false });
		// socket.emit('raw_cmd', { message: "mem rw res_rw0 0x0 0x4", debug:
		// false });
		// socket.emit('raw_cmd', { message: "mem rw res_rw0 0x0 0x1000", debug:
		// false });
		socket.emit('raw_cmd', {
			message : "mem rw res_rw3 0x00000001 0x00000001",
			debug : false
		});
		$("#agc_range").prop("disabled", true);
		$("#agc_display").text("-");
	} else {
		// socket.emit('raw_cmd', { message: "mem rw res_rw0 0x0 0x1", debug:
		// false });
		// socket.emit('raw_cmd', { message: "mem rw res_rw0 0x1000 0x1000",
		// debug: false });
		socket.emit('raw_cmd', {
			message : "mem rw res_rw3 0x00000000 0x00000001",
			debug : false
		});
		$("#agc_range").prop("disabled", false);
		$("#agc_display").text("-" + $("#agc_range").val() / 4 + " dB");
	}
});

// led
$("#led").click(function() {
	socket.emit('prop_wr', {
		file : cur_root + '/board/led',
		message : '5'
	});
});

// Reset buttons
$("#reset_fpga").click(function() {
	socket.emit('prop_wr', {
		file : 'fpga/board/restreq',
		message : '1'
	});
});

// Send uart command
$("#send_uart_cmd").click(function() {
	var cmd = $("#uart_cmd").val();
	if (cmd) {
		socket.emit('raw_cmd', {
			message : "echo '" + cmd + "' | mcu",
			debug : true
		});
	}
});

// pressing enter on uart command redirects a click
$("#uart_cmd").keypress(function(event) {
	if (event.keyCode == 13)
		$("#send_uart_cmd").click();
});

// jesd sync
$("#jesdsync").click(function() {
	socket.emit('prop_wr', {
		file : 'fpga/board/jesd_sync',
		message : '1'
	});
});

// board version
$("#version").click(function() {
	if (cur_board == 'time')
		socket.emit('raw_cmd', {
			message : "echo 'board -v' | mcu -f s",
			debug : true
		});
	else if (cur_board == 'fpga')
		socket.emit('raw_cmd', {
			message : "echo 'board -v' | mcu",
			debug : true
		});
	else if (cur_board == 'tx')
		socket.emit('raw_cmd', {
			message : "echo 'board -v' | mcu -f t",
			debug : true
		});
	else if (cur_board == 'rx')
		socket.emit('raw_cmd', {
			message : "echo 'board -v' | mcu -f r",
			debug : true
		});
});

// board temperature
$("#temperature").click(function() {
	if (cur_board == 'time')
		socket.emit('raw_cmd', {
			message : "echo 'board -t' | mcu -f s",
			debug : true
		});
	else if (cur_board == 'fpga')
		socket.emit('raw_cmd', {
			message : "echo 'board -t' | mcu",
			debug : true
		});
	else if (cur_board == 'tx')
		socket.emit('raw_cmd', {
			message : "echo 'board -c 15 -t' | mcu -f t",
			debug : true
		});
	else if (cur_board == 'rx')
		socket.emit('raw_cmd', {
			message : "echo 'board -c 15 -u' | mcu -f r",
			debug : true
		});
});

// system reset
$("#reset_system").click(function() {
	socket.emit('prop_wr', {
		file : 'fpga/board/sys_rstreq',
		message : '1'
	});
});

// board channel features
$("#chan_init,#chan_demo,#chan_mute,#chan_reset").click(function() {
	$("#adminModal").modal('show');
});

// board test routines
$("[id$=_test]").click(function() {
	$("#adminModal").modal('show');
});

// board dump routines
$("#hmc_dump").click(function() {
	socket.emit('raw_cmd', {
		message : "echo 'dump -f' | mcu -f s",
		debug : true
	});
});

$("#lmk_dump").click(function() {
	socket.emit('raw_cmd', {
		message : "echo 'dump -c' | mcu -f s",
		debug : true
	});
});

$("#dac_dump").click(function() {
	socket.emit('raw_cmd', {
		message : "echo 'dump -c " + cur_chan + " -d' | mcu -f t",
		debug : true
	});
});

$("#gpiox_dump").click(function() {
	if (cur_board == 'tx')
		socket.emit('raw_cmd', {
			message : "echo 'dump -c " + cur_chan + " -g' | mcu -f t",
			debug : true
		});
	else if (cur_board == 'rx')
		socket.emit('raw_cmd', {
			message : "echo 'dump -c " + cur_chan + " -g' | mcu -f r",
			debug : true
		});
});

$("#adc_dump").click(function() {
	socket.emit('raw_cmd', {
		message : "echo 'dump -c " + cur_chan + " -a' | mcu -f r",
		debug : true
	});
});

$("#lmh_dump").click(function() {
	socket.emit('raw_cmd', {
		message : "echo 'dump -c " + cur_chan + " -v' | mcu -f r",
		debug : true
	});
});

// program board
$("#program_start").click(function() {
	var option = $("#program_board option:selected").val();
	// console.log( $('#program_hexfile').prop('files')[0]);
	// socket.emit('hexfile', { board: option, buf:
	// $('#program_hexfile').prop('files')[0] });
});

// gain
$("#gain_range").change(function() {
	var val = parseInt($(this).val());
	$("#gain_display").text('+' + (val / 4) + ' dB');
	socket.emit('prop_wr', {
		file : cur_root + '/rf/gain/val',
		message : val
	});
});

// attenuation (RX Only)
$("atten_range").change(function() {
	$("#agc_display").text('-' + ($(this).val() / 4) + ' dB');
	socket.emit('prop_wr', {
		file : cur_root + '/rf/atten/val',
		message : $(this).val()
	});
});

// i-bias
$("#ibias_range").change(function() {
	$("#ibias_display").text('I: ' + $(this).val() + ' mV');
	socket.emit('prop_wr', {
		file : cur_root + '/rf/freq/i_bias',
		message : ($(this).val() / 100)
	});
});

// q-bias
$("#qbias_range").change(function() {
	$("#qbias_display").text('Q: ' + $(this).val() + ' mV');
	socket.emit('prop_wr', {
		file : cur_root + '/rf/freq/q_bias',
		message : ($(this).val() / 100)
	});
});

// sample rate
$("#bandwidth").change(function() {
//			socket.emit('prop_wr', {
//				file : cur_root + '/dsp/rate',
//				message : $("#bandwidth").val()
//			});
	
	// Filterbank should mostly not change during a bandwidth shift
	var is_rx = cur_root.indexOf('rx') > -1;
	var bw_hex = parseInt($("#bandwidth").val());


	if (!is_rx) {
		
		// Write Bandwidth to FPGA
		socket.emit('raw_cmd', {
			message: "mem rw txa1 0x" + bw_hex.toString(16) + " 0xffff" + ";" + " mem rw txga 60606060; mem rw txa4 2 2"+";"+" mem rw rxa4 2 2; mem rw txa4 0 2; mem rw rxa4 0 2" ,
			debug: false
		});

	} else {

		// Write Bandwidth to FPGA
		socket.emit('raw_cmd', {
			message: "mem rw rxa1 0x" + bw_hex.toString(16) + " 0xffff"+";"+" mem rw rxa4 2 2; mem rw txa4 0 2; mem rw rxa4 0 2",
			debug: false
		});

	}

});

// rf band
$("#rf_band").on('switchChange.bootstrapSwitch', function(event, state) {
	socket.emit('prop_wr', {
		file : cur_root + '/rf/freq/band',
		message : state ? '1' : '0'
	});
});

// lna enable
$("#lna_en").on('switchChange.bootstrapSwitch',	function(event, state) {
	socket.emit('raw_cmd', {
		message : state ? 'mem rw res_rw3 0x00010000 0x00010000'
				: 'mem rw res_rw3 0x00000000 0x00010000'
	});
});

// lna enable
$("#pamp_en").on('switchChange.bootstrapSwitch', function(event, state) {
	socket.emit('raw_cmd', {
		message : state ? 'mem rw res_rw3 0x00020000 0x00020000'
				: 'mem rw res_rw3 0x00000000 0x00020000'
	});
});

// dsp signed data
$("#signed").on('switchChange.bootstrapSwitch', function(event, state) {
	socket.emit('prop_wr', {
		file : cur_root + '/dsp/signed',
		message : state ? '1' : '0'
	});
});

// reference clock
$("#ext_ref").on('switchChange.bootstrapSwitch', function(event, state) {
	socket.emit('prop_wr', {
		file : cur_root + '/source/ref',
		message : state ? 'external' : 'internal'
	});
});

// Enable DevClock Output
//$("#out_devclk_en").on('switchChange.bootstrapSwitch', function(event, state) {
//	socket.emit('prop_wr', {
//		file : cur_root + '/source/devclk',
//		message : state ? 'external' : 'internal'
//	});
//});

// Enable SysRef Output
//$("#out_sysref_en").on('switchChange.bootstrapSwitch', function(event, state) {
//	socket.emit('prop_wr', {
//		file : cur_root + '/source/sync',
//		message : state ? 'external' : 'internal'
//	});
//});

// Enable PLL Output
//$("#out_pll_en").on('switchChange.bootstrapSwitch', function(event, state) {
//	socket.emit('prop_wr', {
//		file : cur_root + '/source/pll',
//		message : state ? 'external' : 'internal'
//	});
//});

// External VCO
//$("#out_vco_en").on('switchChange.bootstrapSwitch', function(event, state) {
//	socket.emit('prop_wr', {
//		file : cur_root + '/source/vco',
//		message : state ? 'external' : 'internal'
//	});
//});

// Send Raw Waveform Data
$("#raw_wave_en").on('switchChange.bootstrapSwitch', function(event, state) {
	socket.emit('raw_cmd', {
		message : state ? 'mem rw res_rw1 0x00000004 0x00000004'
					    : 'mem rw res_rw1 0x00000000 0x00000004',
		debug : false
	});
});

// phase increment
$("#if_set").click(function() {
	var is_rx = cur_root.indexOf('rx') > -1;
	var interfreq = Math.abs(parseInt($("#if").val())) / 1000000;
	
	// Identify Correct Filterbank
	var fb = 4;
	if (interfreq < 7.3) {
		fb = 4;		// 0x04
	} else if (interfreq < 10) {
		fb = 13;	// 0x0D
	} else if (interfreq < 13) {
		fb = 11; 	// 0x0B
	} else if (interfreq < 16) {
		fb = 7;		// 0x07
	} else if (interfreq < 22) {
		fb = 8;		// 0x08
	} else {
		fb = 2;		// 0x02
	}
	
	if (parseInt($("#if").val()) < 0) {					// Negative Intermediate Frequency

		if (!is_rx) {
			
			// Ensure DAC NCO = 0
			socket.emit('prop_wr', {
				file : cur_root + '/rf/dac/nco',
				message : 0
			}); 

			// Select TX Filterbank
			socket.emit('raw_cmd', {
				message: "mem rw res_rw4 0x" + fb.toString(16) + " 0x0000000f",
				debug: false
			});
			
			socket.emit('prop_wr', {
				file : cur_root + '/dsp/nco_adj',
				message : parseInt($("#if").val()) // - (bw * 1000)
			});

		} else {
			
			// Select RXD Filterbank
			socket.emit('raw_cmd', {
				message: "mem rw res_rw4 0x000" + fb.toString(16) + fb.toString(16) + fb.toString(16) + fb.toString(16) + "0 0x000ffff0",
				debug: false
			});
			
			socket.emit('prop_wr', {
				file : cur_root + '/dsp/nco_adj',
				message : parseInt($("#if").val()) // - (bw * 1000)
			});

		}

	} else {											// Positive Intermediate Frequency
		
		if (!is_rx) {
			
			// Ensure DAC NCO = 0
			socket.emit('prop_wr', {
				file : cur_root + '/rf/dac/nco',
				message : 0
			});
			
			// Select TX Filterbank
			socket.emit('raw_cmd', {
				message: "mem rw res_rw4 0x" + fb.toString(16) + " 0x0000000f",
				debug: false
			});
			
			socket.emit('prop_wr', {
				file : cur_root + '/dsp/nco_adj',
				message : parseInt($("#if").val()) // + (bw * 1000)
			});

		} else {
			
			// Select RXD Filterbank
			socket.emit('raw_cmd', {
				message: "mem rw res_rw4 0x000" + fb.toString(16) + fb.toString(16) + fb.toString(16) + fb.toString(16) + "0 0x000ffff0",
				debug: false
			});
			
			socket.emit('prop_wr', {
				file : cur_root + '/dsp/nco_adj',
				message : parseInt($("#if").val()) // - (bw * 1000)
			});

		}

	}
});

// dsp reset
$("#dsp_reset").click(function() {
	socket.emit('prop_wr', {
		file : cur_root + '/dsp/rstreq',
		message : '1'
	});
});

// loopback
$("#loopback").on('switchChange.bootstrapSwitch', function(event, state) {
	socket.emit('prop_wr', {
		file : cur_root + '/dsp/loopback',
		message : state ? '1' : '0'
	});
});

// link settings
$("#link_set").click(function() {
	socket.emit('prop_wr', {
		file : cur_root + '/link/port',
		message : $("#port").val()
	});
	if (cur_board == 'rx') {
		socket.emit('prop_wr', {
			file : cur_root + '/link/ip_dest',
			message : $("#ip").val()
		});
		socket.emit('prop_wr', {
			file : cur_root + '/link/mac_dest',
			message : $("#mac").val()
		});
	}
});

// sfp settings
$("#sfpa_set").click(function() {
	socket.emit('prop_wr', {
		file : 'fpga/link/sfpa/ip_addr',
		message : $("#sfpa_ip").val()
	});
	socket.emit('prop_wr', {
		file : 'fpga/link/sfpa/mac_addr',
		message : $("#sfpa_mac").val()
	});
	socket.emit('prop_wr', {
		file : 'fpga/link/sfpa/pay_len',
		message : $("#sfpa_paylen").val()
	});
});

$("#sfpb_set").click(function() {
	socket.emit('prop_wr', {
		file : 'fpga/link/sfpb/ip_addr',
		message : $("#sfpb_ip").val()
	});
	socket.emit('prop_wr', {
		file : 'fpga/link/sfpb/mac_addr',
		message : $("#sfpb_mac").val()
	});
	socket.emit('prop_wr', {
		file : 'fpga/link/sfpb/pay_len',
		message : $("#sfpb_paylen").val()
	});
});

$("#mgmt_set").click(function() {
	socket.emit('prop_wr', {
		file : 'fpga/link/net/hostname',
		message : $("#hostname").val()
	});
	// if (!$('#dhcp_en').bootstrapSwitch('state'))
	socket.emit('prop_wr', {
		file : 'fpga/link/net/ip_addr',
		message : $("#mgmt_ip").val()
	});
});

// dac nco
$("#dac_nco_set").click(function() {
	if (!$("#dac_nco").val())
		return;
	socket.emit('prop_wr', {
		file : cur_root + '/rf/dac/nco',
		message : $("#dac_nco").val()
	});
});

// mode of operation - pps trigger
$("input[name=op_mode]:radio").change(function() {
	op_mode = $("input[name=op_mode]:checked").val();

	var is_rx = (pathname.indexOf('rx') > -1);
	
	// normal mode
	if ($("input[name=op_mode]:checked").val() == '0') {
		$("#pay_val").prop("disabled", true);
		$("#cd_match_pkts").text("-");
		$("#pay_val_display").text(" - ");
		$("#pps_tick_display1").text(" - ");
		$("#pps_tick_display2").text(" - ");
		$("#pps_tick_display3").text(" - ");
		$("#pps_tick_display4").text(" - ");
		$("#pps_sec_display1").text(" - ");
		$("#pps_sec_display2").text(" - ");
		$("#pps_sec_display3").text(" - ");
		$("#pps_sec_display4").text(" - ");
		$("#cd_clear").click();


		if (is_rx) {
			// Disable RX PPS
			// Disable RX Flood
			// Reset Demod Packet Count
			// Reset Demod Good Packet Count
			socket.emit('raw_cmd', {
				message: "mem rw res_rw1 0x0000c000 0x0000d002",
				debug: false
			});
			
			// Remove Reset Demod Packet Count
			// Remove Reset Demod Good Packet Count
			socket.emit('raw_cmd', {
				message: "mem rw res_rw1 0x00000000 0x0000c000",
				debug: false
			});
		} else {
			// Disable TX PPS
			// Disable TX Flood
			// Reset Mod Packet Count
			socket.emit('raw_cmd', {
				message: "mem rw res_rw0 0x00002000 0x00003002",
				debug: false
			});
			
			// Remove Reset Mod Packet Count
			socket.emit('raw_cmd', {
				message: "mem rw res_rw0 0x00000000 0x00002000",
				debug: false
			});
		}
		
		// pps triggered mode
	} else if ($("input[name=op_mode]:checked").val() == '2') {
		$("#pay_val").prop("disabled", false);
		$("#pps_tick_display1").text(" - ");
		$("#pps_tick_display2").text(" - ");
		$("#pps_tick_display3").text(" - ");
		$("#pps_tick_display4").text(" - ");
		$("#pps_sec_display1").text(" - ");
		$("#pps_sec_display2").text(" - ");
		$("#pps_sec_display3").text(" - ");
		$("#pps_sec_display4").text(" - ");
		$("#cd_clear").click();
		
		if (is_rx) {
			// Disable RX PPS
			// Reset Demod Packet Count
			// Reset Demod Good Packet Count
			// Enable RX Flood
			socket.emit('raw_cmd', {
				message: "mem rw res_rw1 0x0000d000 0x0000d002",
				debug: false
			});
			
			// Set Expected Payload Value
			var exp_data = parseInt($("#pay_val").val(), 16);
			exp_data = exp_data << 4;
			socket.emit('raw_cmd', {
				message: "mem rw res_rw1 0x" + exp_data.toString(16) + " 0x00000ff0",
				debug: false
			});
			
			// Remove Reset Demod Packet Count
			// Remove Demod Good Packet Count
			socket.emit('raw_cmd', {
				message: "mem rw res_rw1 0x00000000 0x0000c000",
				debug: false
			});
		} else {
			// Disable TX PPS
			// Reset Mod Packet Count
			// Enable TX Flood
			socket.emit('raw_cmd', {
				message: "mem rw res_rw0 0x00003000 0x00003002",
				debug: false
			});
			
			// Set Payload Value to Send
			var exp_data = parseInt($("#pay_val").val(), 16);
			exp_data = exp_data << 4;
			socket.emit('raw_cmd', {
				message: "mem rw res_rw0 0x" + exp_data.toString(16) + " 0x00000ff0",
				debug: false
			});
			
			// Remove Reset Mod Packet Count
			socket.emit('raw_cmd', {
				message: "mem rw res_rw0 0x00000000 0x00002000",
				debug: false
			});
		}

	} else {
		$("#pay_val").prop("disabled", false);
		$("#cd_error_pkts").text(" - ");
		$("#cd_error_rate").text(" - ");
		
		if (is_rx) {
			// Reset Demod Packet Count
			// Reset Demod Good Packet Count
			// Disable RX Flood
			// Enable RX PPS
			socket.emit('raw_cmd', {
				message: "mem rw res_rw1 0x0000c002 0x0000d002",
				debug: false
			});
			
			// Set Expected Payload Value
			var exp_data = parseInt($("#pay_val").val(), 16);
			exp_data = exp_data << 4;
			socket.emit('raw_cmd', {
				message: "mem rw res_rw1 0x" + exp_data.toString(16) + " 0x00000ff0",
				debug: false
			});
			
			// Remove Reset Demod Packet Count
			// Remove Demod Good Packet Count
			socket.emit('raw_cmd', {
				message: "mem rw res_rw1 0x00000000 0x0000c000",
				debug: false
			});
		} else {
			// Reset Mod Packet Count
			// Disable TX Flood
			// Enable TX PPS
			socket.emit('raw_cmd', {
				message: "mem rw res_rw0 0x00002002 0x00003002",
				debug: false
			});
			
			// Set Payload Value to Send
			var exp_data = parseInt($("#pay_val").val(), 16);
			exp_data = exp_data << 4;
			socket.emit('raw_cmd', {
				message: "mem rw res_rw0 0x" + exp_data.toString(16) + " 0x00000ff0",
				debug: false
			});
			
			// Remove Reset Mod Packet Count
			socket.emit('raw_cmd', {
				message: "mem rw res_rw0 0x00000000 0x00002000",
				debug: false
			});
		}
	}
});

// clear carrier detect stats, toggle the bit
$("#pay_set").click(function() {
	//var len = parseInt($("#pay_len").val(), 10);
	var val = parseInt($("#pay_val").val(), 16);
	
	if ((pathname.indexOf('tx') > -1)) {
		socket.emit('raw_cmd', {
			message : "mem rw res_rw0 0x" + (val << 4).toString(16) + " 0xff0",
			debug : false
		});
	} else {
		socket.emit('raw_cmd', {
			message : "mem rw res_rw1 0x" + (val << 4).toString(16) + " 0xff0",
			debug : false
		});
	}
});

// Clear Packet Count Statistics
$("#ctr_rst").click(function() {
	var is_rx = pathname.indexOf('rx') > -1;
	
	if (is_rx) {
		// Reset Demod Packet Count
		// Reset Demod Packet Match Count
		socket.emit('raw_cmd', {
			message: "mem rw res_rw1 0x0000c000 0x0000c000",
			debug: false
		});
		
		// Remove Reset Holds
		socket.emit('raw_cmd', {
			message: "mem rw res_rw1 0x00000000 0x0000c000",
			debug: false
		});
	} else {
		// Reset Mod Packet Count
		socket.emit('raw_cmd', {
			message: "mem rw res_rw0 0x00002000 0x00002000",
			debug: false
		});
		
		// Remove Reset Holds
		socket.emit('raw_cmd', {
			message: "mem rw res_rw0 0x00000000 0x00002000",
			debug: false
		});
	}
});

// clear carrier detect stats, toggle the bit
$("#cd_clear").click(function() {
	socket.emit('raw_cmd', {
		message : "mem rw res_rw0 0x8 0x8",
		debug : false
	});
	setTimeout(function() {
		socket.emit('raw_cmd', {
			message : "mem rw res_rw0 0x0 0x8",
			debug : false
		});
	}, 700);
});

// agc range slide
$("#agc_range").change(function() {
	var val = parseInt($(this).val());
	socket.emit('raw_cmd', {
		message : "mem rw res_rw2 0x" + val.toString(16) + " 0x7f",
		debug : false
	});
	$("#agc_display").text("-" + parseInt(val) / 4 + " dB");

});

// hexfile
$("#program_hexfile").change(function() {
	if ($("#program_hexfile").val())
		$("#program_start").removeClass('disabled');
});

// receive console from server
socket.on('raw_reply', function(data) {
	// console.log("Raw reply: " + data.message);

	// non-debug msg
	if (data.debug == false) {
		if (data.cmd == "mem rr res_ro0" && ((op_mode == '1') || (op_mode == '2'))) {
			var ticks = parseInt(data.message, 16);
			$("#pps_tick_display1").text(ticks);
			$("#pps_sec_display1").text(
					(ticks / 161132.8125).toFixed(4));

		} else if (data.cmd == "mem rr res_ro1" && ((op_mode == '1') || (op_mode == '2'))) {
			var ticks = parseInt(data.message, 16);
			$("#pps_tick_display2").text(ticks);
			$("#pps_sec_display2").text(
					(ticks / 161132.8125).toFixed(4));

		} else if (data.cmd == "mem rr res_ro2" && ((op_mode == '1') || (op_mode == '2'))) {
			var ticks = parseInt(data.message, 16);
			$("#pps_tick_display3").text(ticks);
			$("#pps_sec_display3").text(
					(ticks / 161132.8125).toFixed(4));

		} else if (data.cmd == "mem rr res_ro3" && ((op_mode == '1') || (op_mode == '2'))) {
			var ticks = parseInt(data.message, 16);
			$("#pps_tick_display4").text(ticks);
			$("#pps_sec_display4").text(
					(ticks / 161132.8125).toFixed(4));

		} else if (data.cmd == "mem rr res_ro4" && (pathname.indexOf('tx') > -1)) {
			var total = parseInt(data.message, 16);
			$("#cd_total_pkts").text(total);

		} else if (data.cmd == "mem rr res_ro5" && (pathname.indexOf('rx') > -1)) {
			var total = parseInt(data.message, 16);
			$("#cd_total_pkts").text(total);

		} else if (data.cmd == "mem rr res_ro6" && ((op_mode == '1') || (op_mode == '2')) && (pathname.indexOf('rx')> -1)) {
			var match_count = parseInt(data.message, 16);
			$("#cd_match_pkts").text(match_count);		// RX matched packet count

		} else if (data.cmd == "mem rr res_ro7") {
			var val = parseInt(data.message, 16);
			var signal 		=  val & 0x000000ff;
			var payload 	= (val & 0x0000ff00) >> 8;
			var agc_output 	= (val & 0xffff0000) >> 16;
//			$("#signal_str_display").text(
//					Math.round(signal / 0x3ff * 100) + '%');
			if (op_mode == '1') {
				$("#pay_val_display").text("0x" + payload.toString(16));
			}
			
//			if ($("#agc").bootstrapSwitch('state')) {
//				$("#agc_display").text("-");
//			}

		} else if (data.cmd == "mem rr res_rw0") {
			var val = parseInt(data.message, 16);

			// op mode default
			if (val & 0x2) {
				$("input[name=op_mode]:nth(1)").prop('checked', true);
				op_mode = '1';
			} else if (val & 0x00001000) {
				$("input[name=op_mode]:nth(2)").prop('checked', true);
				op_mode = '2';
			}else {
				$("input[name=op_mode]:nth(0)").prop('checked', true);
				op_mode = '0';
			}

			// tx payload
			$("#pay_val").val(((val >> 4) & 0xff).toString(16));
			$("#pay_val").change();
		} else if (data.cmd == "mem rr res_rw1") {
			var val = parseInt(data.message, 16);
			
			// op mode selection
			if (val & 0x2) {
				$("input[name=op_mode]:nth(1)").prop('checked', true);
				op_mode = '1';
			} else if (val & 0x00001000) {
				$("input[name=op_mode]:nth(2)").prop('checked', true);
				op_mode = '2';
			}else {
				$("input[name=op_mode]:nth(0)").prop('checked', true);
				op_mode = '0';
			}
			
			$("#raw_wave_en").bootstrapSwitch('state', (val & 0x4));
			$("#pay_val").val(((val >> 4) & 0xff).toString(16));
			$("#pay_val").change();

		} else if (data.cmd == "mem rr res_rw2") {
			// PE43704 Modem DSA Setting Bits
			var val = parseInt(data.message, 16);
			val = val & 0x0000007f;
			$("#agc_range").val(val);
			if (!$("#agc").bootstrapSwitch('state')) {
				$("#agc_display").text("-" + (val / 4) + " dB");
			} else {
				$("#agc_display").text("-");
			}
		} else if (data.cmd == "mem rr res_rw3") {
			var val = parseInt(data.message, 16);
			var agc_enable = (val & 0x00000001);
			var agc_target = (val & 0x0000001e) >> 1;
			var lna_enable = (val & 0x00010000) >> 16;
			var pamp_enable = (val & 0x00020000) >> 17;
			// var pwr_5v_en = (val & 0x00040000) >> 18;
			// var pwr_3v3_en = (val & 0x00080000) >> 19;

			$("#agc").bootstrapSwitch('state', (agc_enable > 0));
			$("#lna_en").bootstrapSwitch('state', (lna_enable > 0));
			$("#pamp_en").bootstrapSwitch('state', (pamp_enable > 0));
		} else if (data.cmd == "mem rr res_rw4") {
			// var val = parseInt(data.message, 16);
			// Register Contains Modem Filterbank selection bits
			// Nothing to populate on WebUI
		} else if ((data.cmd == "mem rr txa1")) {
			var val = parseInt(data.message, 16);
			if (val == 0) val = 8319;
			$("#bandwidth").val(val.toString());
		} else if ((data.cmd == "mem rr rxa1")) {
			var val = parseInt(data.message, 16);
			if (val == 0) val = 1039;
			$("#bandwidth").val(val.toString());
		}
		return;
	}

	if ($("#chist")) {
		$("#chist").val($("#chist").val() + data.cmd + "\n");
		$("#chist").change();
	}

	if ($("#cout")) {
		$("#cout").val(
				$("#cout").val()
						+ "\n"
						+ data.message.substring(0,
								data.message.length - 3));
		$("#cout").change();
	}
});

// auto scroll-bar
$('#cout,#chist').change(function() {
	$(this).scrollTop($(this)[0].scrollHeight);
});

// receive debug msg from server
socket.on('prop_wr_ret', function(data) {
	if (data.message.indexOf('rf/freq/band') > -1)
		return;

	// console.log(data.message);
	$("#cout").val($("#cout").val() + "\n" + data.message);
	$("#cout").change();
});

// receive data from server
socket.on('prop_ret', function(data) {
	var channel = cur_chan;

	var debug_msg = "Read from " + data.file + ": " + data.message;
	// console.log(debug_msg);
	if (data.debug) {
		$("#cout").val($("#cout").val() + "\n" + debug_msg);
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
		$('#chan_en').bootstrapSwitch('state', parseInt(data.message) != 0,
				true);
		var is_rx = cur_root.indexOf('rx') > -1;

		if (parseInt(data.message) != 0) {
			if (is_rx)
				activateControls_rx(true);
			else
				activateControls_tx(true);
		} else {
			if (is_rx)
				activateControls_rx(false);
			else
				activateControls_tx(false);
		}
	} else if (data.file == cur_root + '/rf/freq/lna') {
		$('#lna_en')
				.bootstrapSwitch('state', parseInt(data.message) == 0, true);
	} else if (data.file == cur_root + '/rf/gain/val') {
		$('#gain_range').val(parseInt(data.message));
		$("#gain_display").text('+' + (parseInt(data.message) / 4) + ' dB');
	} else if (data.file == cur_root + '/rf/atten/val') {
		$('#agc_range').val(parseInt(data.message));
		if (!$("#agc").bootstrapSwitch('state')) {
			$("#agc_display").text('-' + (parseInt(data.message) / 4) + ' dB');
		} else {
			$("#agc_display").text('-');
		}
	} else if (data.file == cur_root + '/rf/freq/band') {
		$('#rf_band').bootstrapSwitch('state', parseInt(data.message) != 0,
				true);
	} else if (data.file == cur_root + '/dsp/signed') {
		$('#signed').bootstrapSwitch('state', parseInt(data.message) != 0, true);
	} else if (data.file == cur_root + '/dsp/nco_adj') {
		$('#if').val(parseInt(data.message));
	} else if (data.file == cur_root + '/link/port') {
		$('#port').val(data.message);
	} else if (data.file == cur_root + '/link/ip_dest') {
		$('#ip').val(data.message);
	} else if (data.file == cur_root + '/link/mac_dest') {
		$('#mac').val(data.message);
	} else if (data.file == cur_root + '/rf/freq/i_bias') {
		$('#ibias_range').val(parseInt(data.message) * 100);
		$("#ibias_display").text('I: ' + parseInt(data.message) * 100 + ' mV');
	} else if (data.file == cur_root + '/rf/freq/q_bias') {
		$('#qbias_range').val(parseInt(data.message) * 100);
		$("#qbias_display").text('Q: ' + parseInt(data.message) * 100 + ' mV');
	} else if (data.file == cur_root + '/rf/dsp/nco_adj') {
		$('#if').val(data.message);
	} else if (data.file == cur_root + '/dsp/loopback') {
		$('#loopback').bootstrapSwitch('state', parseInt(data.message) != 0,
				true);
	} else if (data.file == cur_root + '/source/ref') {
		$('#ext_ref').bootstrapSwitch('state',
				data.message.indexOf('external') > -1, true);
	} else if (data.file == cur_root + '/source/devclk') {
		$("#out_devclk_en").bootstrapSwitch('state',
				data.message.indexOf('external') > -1, true);
	} else if (data.file == cur_root + '/source/sync') {
		$("#out_sysref_en").bootstrapSwitch('state',
				data.message.indexOf('external') > -1, true); // for
		// legacy
		// purposes
	} else if (data.file == cur_root + '/source/pll') {
		$("#out_pll_en").bootstrapSwitch('state',
				data.message.indexOf('external') > -1, true);
	} else if (data.file == cur_root + '/source/vco') {
		$("#out_vco_en").bootstrapSwitch('state',
				data.message.indexOf('external') > -1, true); // for
		// legacy
		// purposes
	}
});

// en/disable the configurations
function activateControls_rx(state) {
	$('#raw_wave_en').bootstrapSwitch('readonly', !state);
	$('#lna_en').bootstrapSwitch('readonly', !state);
	$('#pamp_en').bootstrapSwitch('readonly', !state);
	$("#gain_range").prop('disabled', !state);
	$("#agc").bootstrapSwitch('readonly', !state);
	$("#dsp_reset").prop('disabled', !state);
	$("#ip").prop('disabled', !state);
	$("#link_set").prop('disabled', !state);
	$("#mac").prop('disabled', !state);
	$("#port").prop('disabled', !state);
	$("#if").prop('disabled', !state);
	$("#if_set").prop('disabled', !state);
	$("#bandwidth").prop('disabled', !state);
}

function activateControls_tx(state) {
	$("#gain_range").prop('disabled', !state);
	$("#dsp_reset").prop('disabled', !state);
	$("#link_set").prop('disabled', !state);
	$("#port").prop('disabled', !state);
	$("#if").prop('disabled', !state);
	$("#if_set").prop('disabled', !state);
	$("#bandwidth").prop('disabled', !state);
}

// write the current settings to SDR
function write_rx() {
	$("#bandwidth").val(3);
	socket.emit('raw_cmd', {
		message: "mem rw rxa1 0x0003 0xffff",
		debug: false
	});
	$("#if").val('-10265000');
	$("#if_set").click();
	socket.emit('prop_wr', {
		file : cur_root + '/rf/gain/val',
		message : $('#gain_range').val()
	});
	socket.emit('prop_wr', {
		file : cur_root + '/rf/atten/val',
		message : $('#atten_range').val()
	});
	socket.emit('prop_wr', {
		file : cur_root + '/dsp/signed',
		message : $('#signed').bootstrapSwitch('state') ? '1' : '0'
	});
	socket.emit('prop_wr', {
		file : cur_root + '/link/port',
		message : $('#port').val()
	});
	socket.emit('prop_wr', {
		file : cur_root + '/link/ip_dest',
		message : $('#ip').val()
	});
	socket.emit('prop_wr', {
		file : cur_root + '/link/mac_dest',
		message : $('#mac').val()
	});
	if ($("#agc").bootstrapSwitch('state')) {
		socket.emit('raw_cmd', {
			message: "mem rr res_ro7",
			debug: false
		});
	} else {
		socket.emit('prop_rd', {
			file: cur_root + '/rf/atten/val',
			debug: false
		});
	}
	
	// AGC default Enable
	socket.emit('raw_cmd', {
		message: "mem rw res_rw3 0x1 0x1",
		debug: false
	});
}

function write_tx() {
	$("#bandwidth").val(1023);
	socket.emit('raw_cmd', {
		message: "mem rw txa1 0x03ff 0xffff",
		debug: false
	});
	$("#if").val('10265000');
	$("#if_set").click();
	socket.emit('prop_wr', {
		file : cur_root + '/rf/gain/val',
		message : $('#gain_range').val()
	});
	socket.emit('prop_wr', {
		file : cur_root + '/link/port',
		message : $('#port').val()
	});
}

// Loading config data
function load_config(isLoad) {
	socket.emit('prop_rd', {
		file : 'fpga/link/sfpa/ip_addr',
		debug : isLoad
	});
	socket.emit('prop_rd', {
		file : 'fpga/link/sfpa/mac_addr',
		debug : isLoad
	});
	socket.emit('prop_rd', {
		file : 'fpga/link/sfpa/pay_len',
		debug : isLoad
	});
	socket.emit('prop_rd', {
		file : 'fpga/link/sfpb/ip_addr',
		debug : isLoad
	});
	socket.emit('prop_rd', {
		file : 'fpga/link/sfpb/mac_addr',
		debug : isLoad
	});
	socket.emit('prop_rd', {
		file : 'fpga/link/sfpb/pay_len',
		debug : isLoad
	});
	socket.emit('prop_rd', {
		file : 'fpga/link/net/dhcp_en',
		debug : isLoad
	});
	socket.emit('prop_rd', {
		file : 'fpga/link/net/hostname',
		debug : isLoad
	});
	socket.emit('prop_rd', {
		file : 'fpga/link/net/ip_addr',
		debug : isLoad
	});
}

function load_rx(isLoad) {
	socket.emit('prop_rd', {
		file : cur_root + '/rf/gain/val',
		debug : isLoad
	});
	socket.emit('prop_rd', {
		file : cur_root + '/rf/atten/val',
		debug : isLoad
	});
	socket.emit('prop_rd', {
		file : cur_root + '/dsp/signed',
		debug : isLoad
	});
//	socket.emit('prop_rd', {
//		file : cur_root + '/dsp/rate',
//		debug : isLoad
//	});
	socket.emit('raw_cmd', {	// Bandwidth
		message: "mem rr rxa1",
		debug: false
	});
	socket.emit('prop_rd', {
		file : cur_root + '/link/port',
		debug : isLoad
	});
	socket.emit('prop_rd', {
		file : cur_root + '/link/ip_dest',
		debug : isLoad
	});
	socket.emit('prop_rd', {
		file : cur_root + '/link/mac_dest',
		debug : isLoad
	});
	socket.emit('prop_rd', {
		file : cur_root + '/pwr',
		debug : isLoad
	});
	setTimeout(function() {
		socket.emit('prop_rd', {
			file : cur_root + '/dsp/nco_adj',
			debug : isLoad
		});
	}, 250);
	socket.emit('raw_cmd', {
		message : "mem rr res_rw1",
		debug : false
	});

	socket.emit('raw_cmd', {
		message: "mem rr res_rw3",
		debug: false
	});
	
	socket.emit('raw_cmd', {
		message: "mem rr res_rw2",
		debug: false
	});
}

function load_tx(isLoad) {
	socket.emit('prop_rd', {
		file : cur_root + '/rf/gain/val',
		debug : isLoad
	});
	socket.emit('raw_cmd', {	// Bandwidth
		message: "mem rr txa1",
		debug: false
	});
	socket.emit('prop_rd', {
		file : cur_root + '/link/port',
		debug : isLoad
	});
	socket.emit('prop_rd', {
		file : cur_root + '/pwr',
		debug : isLoad
	});
	setTimeout(function() {
		socket.emit('prop_rd', {
			file : cur_root + '/dsp/nco_adj',
			debug : isLoad
		});
	}, 250);
	socket.emit('raw_cmd', {
		message : "mem rr res_rw0",
		debug : false
	});
}

function load_clock(isLoad) {
//	socket.emit('prop_rd', {
//		file : cur_root + '/source/vco',
//		debug : isLoad
//	});
//	socket.emit('prop_rd', {
//		file : cur_root + '/source/sync',
//		debug : isLoad
//	});
//	socket.emit('prop_rd', {
//		file : cur_root + '/source/devclk',
//		debug : isLoad
//	});
//	socket.emit('prop_rd', {
//		file : cur_root + '/source/pll',
//		debug : isLoad
//	});
	socket.emit('prop_rd', {
		file : cur_root + '/source/ref',
		debug : isLoad
	});
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
		// loadFunc = load_debug;
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
	// var refreshID = setInterval(loadFunc, 3000);

	// update display boxes periodically
	setInterval(updateDisplay, 800);
}

function updateDisplay() {
	
	if ((op_mode == '1') && (pathname.indexOf('rx') > -1)) {	// if pps triggered mode

		// update latency readings
		socket.emit('raw_cmd', {	// Latency 0
			message : "mem rr res_ro0",
			debug : false
		});
		socket.emit('raw_cmd', {	// Latency 1
			message : "mem rr res_ro1",
			debug : false
		});
		socket.emit('raw_cmd', {	// Latency 2
			message : "mem rr res_ro2",
			debug : false
		});
		socket.emit('raw_cmd', {	// Latency 3
			message : "mem rr res_ro3",
			debug : false
		});
		socket.emit('raw_cmd', {	// Recv Packet Count
			message : "mem rr res_ro5",
			debug : false
		});
		socket.emit('raw_cmd', {	// Recv Matched Packet Count
			message : "mem rr res_ro6",
			debug : false
		});
		socket.emit('raw_cmd', {	// Recv Data
			message : "mem rr res_ro7",
			debug : false
		});

	} else if ((op_mode == '2') && (pathname.indexOf('rx') > -1)) {		// Flood Mode
		socket.emit('raw_cmd', {	// Recv Packet Count
			message : "mem rr res_ro5",
			debug : false
		});
		socket.emit('raw_cmd', {	// Recv Matched Packet Count
			message : "mem rr res_ro6",
			debug : false
		});
		socket.emit('raw_cmd', {	// Recv Data
			message : "mem rr res_ro7",
			debug : false
		});
	} else if (pathname.indexOf('tx') > -1) {
		socket.emit('raw_cmd', {	// Sent Packet Count
			message : "mem rr res_ro4",
			debug : false
		});
	} else {
		socket.emit('raw_cmd', {	// Recv Packet Count
			message : "mem rr res_ro5",
			debug : false
		});
		$("#cd_match_pkts").text("-");
	}
}
