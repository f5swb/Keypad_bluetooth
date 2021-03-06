###############################################################################
#
# Generic Logic event handlers
#
###############################################################################

#
# This is the namespace in which all functions and variables below will exist.
#
namespace eval Logic {


#
# A variable used to store a timestamp for the last identification.
#
variable prev_ident 0;

#
# A constant that indicates the minimum time in seconds to wait between two
# identifications. Manual and long identifications is not affected.
#
variable min_time_between_ident 120;

#
# Short and long identification intervals. They are setup from config
# variables below.
#
variable short_ident_interval 0;
variable long_ident_interval 0;

variable short_voice_id_enable  1
variable short_cw_id_enable     0
variable short_announce_enable  0
variable short_announce_file    ""

variable long_voice_id_enable   1
variable long_cw_id_enable      0
variable long_announce_enable   0
variable long_announce_file     ""

#
# The ident_only_after_tx variable indicates if identification is only to
# occur after the node has transmitted. The variable is setup below from the
# configuration variable with the same name.
# The need_ident variable indicates if identification is needed.
#
variable ident_only_after_tx 0;
variable need_ident 0;

#
# List of functions that should be called periodically. Use the
# addMinuteTickSubscriber and addSecondTickSubscriber functions to
# add subscribers.
#
variable minute_tick_subscribers [list];
variable second_tick_subscribers [list];

#
# Contains the ID of the last receiver that indicated squelch activity
#
variable sql_rx_id "?";

#
# Executed when the SvxLink software is started
#
proc startup {} {
  #playMsg "Core" "online"
  #send_short_ident

#	variable room;

#	set fp [open "/etc/spotnik/network" "r"];
#	set room [string tolower [gets $fp]]

#	puts "**** Salon: $room ****";
	
#	if {"$room" != "default"} {
#		playMsg "RRF" "S$room"
#	}

}


#
# Executed when a specified module could not be found
#   module_id - The numeric ID of the module
#
proc no_such_module {module_id} {
  playMsg "Core" "no_such_module";
  playNumber $module_id;
}


#
# Executed when a manual identification is initiated with the * DTMF code
#
proc manual_identification {} {
  global mycall;
  global report_ctcss;
  global active_module;
  global loaded_modules;
  variable CFG_TYPE;
  variable prev_ident;

  set epoch [clock seconds];
  set hour [clock format $epoch -format "%k"];
  regexp {([1-5]?\d)$} [clock format $epoch -format "%M"] -> minute;
  set prev_ident $epoch;

  playMsg "Core" "online";
  spellWord $mycall;
  if {$CFG_TYPE == "Repeater"} {
    playMsg "Core" "repeater";
  }
  playSilence 250;
  playMsg "Core" "the_time_is";
  playTime $hour $minute;
  playSilence 250;
  if {$report_ctcss > 0} {
    playMsg "Core" "pl_is";
    playFrequency $report_ctcss
    playSilence 300;
  }
  if {$active_module != ""} {
    playMsg "Core" "active_module";
    playMsg $active_module "name";
    playSilence 250;
    set func "::";
    append func $active_module "::status_report";
    if {"[info procs $func]" ne ""} {
      $func;
    }
  } else {
    foreach module [split $loaded_modules " "] {
      set func "::";
      append func $module "::status_report";
      if {"[info procs $func]" ne ""} {
	$func;
      }
    }
  }
#  playMsg "Default" "press_0_for_help"
#  playSilence 250;
}


#
# Executed when a short identification should be sent
#   hour    - The hour on which this identification occur
#   minute  - The minute on which this identification occur
#
proc send_short_ident {{hour -1} {minute -1}} {
  global mycall;
  global report_ctcss;
  variable CFG_TYPE;
  variable short_announce_file
  variable short_announce_enable
  variable short_voice_id_enable
  variable short_cw_id_enable

  # Play voice id if enabled
  if {$short_voice_id_enable} {
    puts "Playing short voice ID"
    spellWord $mycall;
    if {$CFG_TYPE == "Repeater"} {
      playMsg "Core" "repeater";
    }
    playSilence 500;
# if {$report_ctcss > 0} {
#    playMsg "Core" "pl_is";
#    playFrequency $report_ctcss
#    playSilence 300;
#  }

#  }
	  playMsg "Core" "the_time_is";
    playSilence 100;
    playTime $hour $minute;
    playSilence 500;

  # Play announcement file if enabled
  if {$short_announce_enable} {
    puts "Playing short announce"
    if [file exist "$short_announce_file"] {
      playFile "$short_announce_file"
      playSilence 500
    }
  }

  # Play CW id if enabled
  if {$short_cw_id_enable} {
    puts "Playing short CW ID"
    if {$CFG_TYPE == "Repeater"} {
      set call "$mycall/R"
      CW::play $call
    } else {
      CW::play $mycall
    }
    playSilence 500;
  }
}


#
# Executed when a long identification (e.g. hourly) should be sent
#   hour    - The hour on which this identification occur
#   minute  - The minute on which this identification occur
#
proc send_long_ident {hour minute} {
  global mycall;
  global loaded_modules;
  global active_module;
  global report_ctcss;
  variable CFG_TYPE;
  variable long_announce_file
  variable long_announce_enable
  variable long_voice_id_enable
  variable long_cw_id_enable

  # Play the voice ID if enabled
  if {$long_voice_id_enable} {
    puts "Playing Long voice ID"
    spellWord $mycall;
    if {$CFG_TYPE == "Repeater"} {
      playMsg "Core" "repeater";
    }
    playSilence 500;
# if {$report_ctcss > 0} {
#    playMsg "Core" "pl_is";
#    playFrequency $report_ctcss
#    playSilence 300;
#  }
    playMsg "Core" "the_time_is";
    playSilence 100;
    playTime $hour $minute;
    playSilence 500;

    # Call the "status_report" function in all modules if no module is active
    if {$active_module == ""} {
      foreach module [split $loaded_modules " "] {
        set func "::";
        append func $module "::status_report";
        if {"[info procs $func]" ne ""} {
          $func;
        }
      }
    }

    playSilence 500;
  }

  # Play announcement file if enabled
  if {$long_announce_enable} {
    puts "Playing long announce"
    if [file exist "$long_announce_file"] {
      playFile "$long_announce_file"
      playSilence 500
    }
  }

  # Play CW id if enabled
  if {$long_cw_id_enable} {
    puts "Playing long CW ID"
    if {$CFG_TYPE == "Repeater"} {
      set call "$mycall/R"
      CW::play $call
    } else {
      CW::play $mycall
    }
    playSilence 100
  }
}


#
# Executed when the squelch have just closed and the RGR_SOUND_DELAY timer has
# expired.
#
proc send_rgr_sound {} {
  variable sql_rx_id

  if {$sql_rx_id != "?"} {
    # 150 CPM, 1000 Hz, -4 dBFS
    CW::play $sql_rx_id 150 1000 -4
    set sql_rx_id "?"
  } else {
    CW::play "  K"  150 600 -8
  }
  playSilence 100
}


#
# Executed when an empty macro command (i.e. D#) has been entered.
#
proc macro_empty {} {
  playMsg "Core" "operation_failed";
}


#
# Executed when an entered macro command could not be found
#
proc macro_not_found {} {
  playMsg "Core" "operation_failed";
}


#
# Executed when a macro syntax error occurs (configuration error).
#
proc macro_syntax_error {} {
  playMsg "Core" "operation_failed";
}


#
# Executed when the specified module in a macro command is not found
# (configuration error).
#
proc macro_module_not_found {} {
  playMsg "Core" "operation_failed";
}


#
# Executed when the activation of the module specified in the macro command
# failed.
#
proc macro_module_activation_failed {} {
  playMsg "Core" "operation_failed";
}


#
# Executed when a macro command is executed that requires a module to
# be activated but another module is already active.
#
proc macro_another_active_module {} {
  global active_module;

  playMsg "Core" "operation_failed";
  playMsg "Core" "active_module";
  playMsg $active_module "name";
}


#
# Executed when an unknown DTMF command is entered
#   cmd - The command string
#
proc unknown_command {cmd} {
  spellWord $cmd;
  playMsg "Core" "unknown_command";
}


#
# Executed when an entered DTMF command failed
#   cmd - The command string
#
proc command_failed {cmd} {
  spellWord $cmd;
  playMsg "Core" "operation_failed";
}


#
# Executed when a link to another logic core is activated.
#   name  - The name of the link
#
proc activating_link {name} {
  if {[string length $name] > 0} {
    playMsg "Core" "activating_link_to";
    spellWord $name;
  }
}


#
# Executed when a link to another logic core is deactivated.
#   name  - The name of the link
#
proc deactivating_link {name} {
  if {[string length $name] > 0} {
    playMsg "Core" "deactivating_link_to";
    spellWord $name;
  }
}


#
# Executed when trying to deactivate a link to another logic core but the
# link is not currently active.
#   name  - The name of the link
#
proc link_not_active {name} {
  if {[string length $name] > 0} {
    playMsg "Core" "link_not_active_to";
    spellWord $name;
  }
}


#
# Executed when trying to activate a link to another logic core but the
# link is already active.
#   name  - The name of the link
#
proc link_already_active {name} {
  if {[string length $name] > 0} {
    playMsg "Core" "link_already_active_to";
    spellWord $name;
  }
}


#
# Executed each time the transmitter is turned on or off
#   is_on - Set to 1 if the transmitter is on or 0 if it's off
#
proc transmit {is_on} {
  #puts "Turning the transmitter $is_on";
  variable prev_ident;
  variable need_ident;
  if {$is_on && ([clock seconds] - $prev_ident > 5)} {
    set need_ident 1;
  }
}


#
# Executed each time the squelch is opened or closed
#   rx_id   - The ID of the RX that the squelch opened/closed on
#   is_open - Set to 1 if the squelch is open or 0 if it's closed
#
proc squelch_open {rx_id is_open} {
  variable sql_rx_id;
  #puts "The squelch is $is_open on RX $rx_id";
  set sql_rx_id $rx_id;
}


#
# Executed when a DTMF digit has been received
#   digit     - The detected DTMF digit
#   duration  - The duration, in milliseconds, of the digit
#
# Return 1 to hide the digit from further processing in SvxLink or
# return 0 to make SvxLink continue processing as normal.
#
proc dtmf_digit_received {digit duration} {
  #puts "DTMF digit \"$digit\" detected with duration $duration ms";
  return 0;
}


#
# Executed when a DTMF command has been received
#   cmd - The command
#
# Return 1 to hide the command from further processing is SvxLink or
# return 0 to make SvxLink continue processing as normal.
#
# This function can be used to implement your own custom commands or to disable
# DTMF commands that you do not want users to execute.

# dvs=/opt/Analog_Bridge/dvswitch.sh

proc dtmf_cmd_received {cmd} {

#set dvs "/opt/Analog_Bridge/dvswitch.sh"
### modif TK4LS
proc dvswitchQSY {cmd ambemode mode tune nom} {
    set dvs "/opt/Analog_Bridge/dvswitch.sh";
    exec $dvs ambemode $ambemode
    exec $dvs mode $mode
    exec $dvs tune $tune
    #playSilence 150
    #playMsg "NUM" $nom;
    #if {$mode != "YSF" && $mode != "P25" && $mode != "NXDN"} {
     #   playSilence 150;
      #  if {[string length $cmd] == "3"} {
       #     playNumber $cmd;
        #} elseif { [string length $cmd] == "4" } {
         #   playNumber [string range $cmd 0 1];
          #  playSilence 50;
           # playNumber [string range $cmd 2 3];
       # } elseif {[string length $cmd] == "5"} {
        #    playNumber [string range $cmd 0 3];
         #   playSilence 50;
       #     playNumber [string range $cmd 4 5 ];
       # }

   # }

  }

#global active_module

  # Example: Ignore all commands starting with 3 in the EchoLink module.
  #          Allow commands that have four or more digits.
  #if {$active_module == "EchoLink"} {
  #  if {[string length $cmd] < 4 && [string index $cmd 0] == "3"} {
  #    puts "Ignoring random connect command for module EchoLink: $cmd"
  #    return 1
  #  }
  #}

  # Handle the "force core command" mode where a command is forced to be
  # executed by the core command processor instead of by an active module.
  # The "force core command" mode is entered by prefixing a command by a star.
  #if {$active_module != "" && [string index $cmd 0] != "*"} {
  #  return 0
  #}
  #if {[string index $cmd 0] == "*"} {
  #  set cmd [string range $cmd 1 end]
  #}

  # Example: Custom command executed when DTMF 99 is received
  #if {$cmd == "99"} {
  #  puts "Executing external command"
  
  #  playMsg "Core" "online"
  #  exec ls &
  #  return 1
  #}
  
  proc sayIP {} {
    set result [exec /etc/spotnik/getIP]
    puts "$result"

    regexp "(\[0-9]{1,3})\.(\[0-9]{1,3})\.(\[0-9]{1,3})\.(\[0-9]{1,3})" $result all first second third fourth

    playSilence 100
    playNumber $first
    playSilence 100
    playMsg "default" "decimal"
    playSilence 100
    playNumber $second
    playSilence 100
    playMsg "default" "decimal"
    playSilence 100
    playNumber $third
    playSilence 100
    playMsg "default" "decimal"
    playSilence 100
    playNumber $fourth
    playSilence 500;
  }

  # internet test
  proc sayInternetStatus {} {
    if {[catch {exec ping -c 1 google.com} result] == 0} {
      puts "Internet Online Passed"
      playSilence 100
      playMsg "Core" "online"
    } else {
      puts "Internet Disconnected"
      playSilence 100
      playMsg "EchoLink" "link"
      playMsg "EchoLink" "disconnected"
    }
  }

# 300 Kill timersalon
     if {$cmd == "300"} {
     if { [file exists /tmp/TIMER] ==1} {
       file delete -force /tmp/TIMER
       exec nohup /etc/spotnik/timersalon.sh &
       puts "************************************"
       puts "**** ACTIVATION TIMER SALON ******"
       puts "************************************"
       playMsg "RRF" "timerOn"
 } elseif {[file exists /tmp/TIMER] ==0} {
       set outfile [open "/tmp/TIMER" w]
       puts $outfile "TIMER OFF"
       close $outfile
       puts "***************************************"
       puts "**** DESACTIVATION TIMER SALON ******"
       puts "***************************************"
       playMsg "RRF" "timerOff"
       exec pkill -f timersalon
     }
     return 1
   }

  # 400 DTMF controler  
    if { [file exists /tmp/DTMF] } {
    if {$cmd != "400"} {
      return 1
    }
  }

  # 400 DTMF controler
    if {$cmd == "400"} {
    if { [file exists /tmp/DTMF] } {
      file delete -force /tmp/DTMF
      playMsg "RRF" "dtmf_active"
      puts "***********************************"
      puts "***** ACTIVATION DTMF SALON *******"
      puts "***********************************"
    } else {
      set outfile [open "/tmp/DTMF" w]
      puts $outfile "DTMF OFF"
      close $outfile
      playMsg "RRF" "dtmf_desactive"
      puts "***************************************"
      puts "***** DESACTIVATION DTMF        *******"
      puts "***************************************"
    }
    return 1
  }

  # Say if online or offline
  if {$cmd == "939"} {
    sayInternetStatus
    return 1
  }

  # Say the IP adress 
  if {$cmd == "93"} {
    sayIP
    return 1
  }

  if {$cmd == "94"} {
    puts "Executing external command"
    exec /usr/bin/nmcli con up SPOTNIK 
    exec /usr/bin route del default 
    return 1
  }


#
# DTMF KeypadRemote  
# 

 if {$cmd == "195"} {
   puts "Confirmation salon PER"
   playFile /usr/share/svxlink/sounds/fr_FR/RRF/confirmQSY.wav
   playFile /usr/share/svxlink/sounds/fr_FR/RRF/parrot.wav
   return 1
   }



 if {$cmd == "196"} {

     puts "Confirmation salon RRF"
     playFile /usr/share/svxlink/sounds/fr_FR/RRF/confirmQSY.wav
     playFile /usr/share/svxlink/sounds/fr_FR/RRF/Srrf.wav
     return 1
    }

  if {$cmd == "198"} {

     puts "Confirmation salon TEC"
     playFile /usr/share/svxlink/sounds/fr_FR/RRF/confirmQSY.wav
     playFile /usr/share/svxlink/sounds/fr_FR/RRF/Stec.wav
    return 1
    }
if {$cmd == "199"} {

     puts "Confirmation salon INT"
     playFile /usr/share/svxlink/sounds/fr_FR/RRF/confirmQSY.wav
     playFile /usr/share/svxlink/sounds/fr_FR/RRF/Sint.wav
     return 1
     }

if {$cmd == "1100"} {

     puts "Confirmation salon BAV"
     playFile /usr/share/svxlink/sounds/fr_FR/RRF/confirmQSY.wav
     playFile /usr/share/svxlink/sounds/fr_FR/RRF/Sbav.wav
     return 1
     }

if {$cmd == "1101"} {

     puts "Confirmation salon LOC"
     playFile /usr/share/svxlink/sounds/fr_FR/RRF/confirmQSY.wav
     playFile /usr/share/svxlink/sounds/fr_FR/RRF/Sloc.wav
     return 1
     }
if {$cmd == "1102"} {

     puts "Confirmation salon EXP"
     playFile /usr/share/svxlink/sounds/fr_FR/RRF/confirmQSY.wav
     playFile /usr/share/svxlink/sounds/fr_FR/RRF/Sexp.wav
     return 1
     }
if {$cmd == "1103"} {

     puts "Confirmation salon REG"
     playFile /usr/share/svxlink/sounds/fr_FR/RRF/confirmQSY.wav
     playFile /usr/share/svxlink/sounds/fr_FR/RRF/Sreg.wav
     return 1
     }
if {$cmd == "1104"} {

     puts "Confirmation annonce METEO"
     playFile /usr/share/svxlink/sounds/fr_FR/RRF/confirm.wav
     playFile /usr/share/svxlink/sounds/fr_FR/RRF/meteo.wav
     return 1
     }

if {$cmd == "1105"} {

     puts "Confirmation annonce IP"
     playFile /usr/share/svxlink/sounds/fr_FR/RRF/confirm.wav
     playFile /usr/share/svxlink/sounds/fr_FR/RRF/adresse.wav
     return 1
     }

if {$cmd == "197"} {

     puts "Confirmation salon FON"
     playFile /usr/share/svxlink/sounds/fr_FR/RRF/confirmQSY.wav
     playFile /usr/share/svxlink/sounds/fr_FR/RRF/Sfon.wav
     return 1
     }

#DONNER EN VOCAL LE SALLON EN COURS
if {$cmd == "88"} {

  if { [file exists /etc/spotnik/network]  } {
        set sa [open "/etc/spotnik/network" "r"]
        set salon [read $sa]

  if  [string match "*rrf*" $salon] then {
                puts "Reseau RRF";
                playMsg "RRF" "Srrf";
        }

  if  [string match "*tec*" $salon] then {
                puts "Salon Technique";
                playMsg "RRF" "Stec";
  }
  if  [string match "*loc*" $salon] then {
                puts "Salon Local";
                playMsg "RRF" "Sloc";
        }
  if  [string match "*int*" $salon] then {
                puts "Salon Internationnal";
                playMsg "RRF" "Sinter";
        }
  if  [string match "*bav*" $salon] then {
                puts "Salon Bavardage";
                playMsg "RRF" "Sbav";
  }
  if  [string match "*fon*" $salon] then {
                puts "Reseau FON";
                playMsg "RRF" "Sfon";
  }
  if  [string match "*reg*" $salon] then {
                puts "Reseau Regional";
                playMsg "RRF" "Sreg";
  }
  if  [string match "*exp*" $salon] then {
                puts "Reseau Experimental";
                playMsg "RRF" "Sexp";
   }
  if  [string match "*default*" $salon] then {
                puts "Repeteur perroquet";
                playMsg "RRF" "parrot";
   }

   }
     return 1
     }



# Mode Perroquet
  if {$cmd == "95"} {
     exec nohup /etc/spotnik/restart.default &
	puts "**********************************"
	puts "******** MODE PERROQUET **********"
	puts "**********************************"
    return 1
  }


# 96 SvxReflector RRF
  if {$cmd == "96"} {
     exec nohup /etc/spotnik/restart.rrf &
	puts "**********************************"
	puts "******** RESEAU RRF **************"
	puts "**********************************"
    return 1
  }

# 97 SvxReflector FON
  if {$cmd == "97"} {
     exec nohup /etc/spotnik/restart.fon &
	puts "**********************************"
	puts "******** RESEAU FON **************"
	puts "**********************************"
    return 1
  }


# 98 Salon Technique  
  if {$cmd == "98"} {
     exec nohup /etc/spotnik/restart.tec &
	puts "**********************************"
	puts "***** SALON TECHNIQUE ************"
	puts "**********************************"
    return 1
  }

# 99 Salon International  
  if {$cmd == "99"} {
     exec nohup /etc/spotnik/restart.int &
	puts "**********************************"
	puts "***** SALON INTERNATIONAL ********"
	puts "**********************************"
    return 1
  }

# 100 Salon Bavardage  
  if {$cmd == "100"} {
     exec nohup /etc/spotnik/restart.bav &
	puts "**********************************"
	puts "***** SALON BAVARDAGE ************"
	puts "**********************************"
    return 1
  }

# 101 Salon Local  
  if {$cmd == "101"} {
     exec nohup /etc/spotnik/restart.loc &
	puts "**********************************"
	puts "******* SALON LOCAL **************"
	puts "**********************************"
    return 1
  }

# 102 salon Experimental  
  if {$cmd == "102"} {
     exec nohup /etc/spotnik/restart.exp &
	puts "**********************************"
	puts "***** SALON EXPERIMENTAL**********"
	puts "**********************************" 
    return 1
  }

# 103 Echolink  
  if {$cmd == "103"} {
     exec nohup /etc/spotnik/restart.el &
	puts "**********************************"
	puts "********* ECHOLINK ***************"
	puts "**********************************" 
	return 1
  }

# 104 Regional  
  if {$cmd == "104"} {
     exec nohup /etc/spotnik/restart.reg &
	puts "**********************************"
	puts "******** SALON REGIONAL **********"
	puts "**********************************" 
	
    return 1
  }


# 200 Raptor start and stop
  if {$cmd == "200"} {
    puts "Executing external command"
    exec nohup /opt/RRFRaptor/RRFRaptor.sh &
    return 1
  }

# 201 Raptor quick scan
  if {$cmd == "201"} {
    puts "Executing external command"
    exec /opt/RRFRaptor/RRFRaptor.sh scan
    return 1
  }

# 202 Raptor sound
  if {$cmd == "202"} {
    if { [file exists /tmp/RRFRaptor_status.tcl] } {
      source "/tmp/RRFRaptor_status.tcl"
      if {$RRFRaptor == "ON"} {
        playSilence 1500
        playFile /opt/RRFRaptor/sounds/active.wav     
      } else {
        playSilence 1500
        playFile /opt/RRFRaptor/sounds/desactive.wav
      }
    }
    return 1
  }


# 203 Raptor quick scan sound
  if {$cmd == "203"} {
    if { [file exists /tmp/RRFRaptor_scan.tcl] } {
      source "/tmp/RRFRaptor_scan.tcl"
      if {$RRFRaptor == "None"} {
        playSilence 1500
        playFile /opt/RRFRaptor/sounds/qso_ko.wav        
      } else {
        playSilence 1500
        playFile /opt/RRFRaptor/sounds/qso_ok.wav
        if {$RRFRaptor == "RRF"} {
          playFile /usr/share/svxlink/sounds/fr_FR/RRF/Srrf.wav      
        } elseif {$RRFRaptor == "FON"} {
          playFile /usr/share/svxlink/sounds/fr_FR/RRF/Sfon.wav    
        } elseif {$RRFRaptor == "TECHNIQUE"} {
          playFile /usr/share/svxlink/sounds/fr_FR/RRF/Stec.wav    
        } elseif {$RRFRaptor == "INTERNATIONAL"} {
          playFile /usr/share/svxlink/sounds/fr_FR/RRF/Sint.wav    
        } elseif {$RRFRaptor == "LOCAL"} {
          playFile /usr/share/svxlink/sounds/fr_FR/RRF/Sloc.wav    
        } elseif {$RRFRaptor == "BAVARDAGE"} {
          playFile /usr/share/svxlink/sounds/fr_FR/RRF/Sbav.wav    
        }  
      }
    }
    return 1
  }

### MODE NUMERIQUE YSF ###

# YSF-FRANCE
  if {$cmd == "3000"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sc4fm"
  playMsg "Core" "ysffrance"
  exec nohup /etc/spotnik/restart.ysf 3000 &
  return 1
  }

  # YSF-IDF
  if {$cmd == "3001"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sc4fm"
  playMsg "Core" "idf"
  exec nohup /etc/spotnik/restart.ysf 3001 &
  return 1
  }

# YSF-Est
  if {$cmd == "3002"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sc4fm"
  playMsg "Core" "ysfalsace"
  exec nohup /etc/spotnik/restart.ysf 3002 &

  return 1
  }

# YSF-ZIT
  if {$cmd == "3003"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sc4fm"
  playMsg "Core" "roomzit"
  exec nohup /etc/spotnik/restart.ysf 3003 &
  return 1
  }

# YSF-Centre France
  if {$cmd == "3004"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sc4fm"
  playMsg "Core" "centrefrance"
  exec nohup /etc/spotnik/restart.ysf 3004 &
  return 1
  }

# YSF-Alpes
  if {$cmd == "3005"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sc4fm"
  playMsg "Core" "ysfalpes"
  exec nohup /etc/spotnik/restart.ysf 3005 &
  return 1
  }

# YSF-WALONNIE
  if {$cmd == "3006"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sc4fm"
  playMsg "Core" "ysfwallonie"
  exec nohup /etc/spotnik/restart.ysf 3006 &
  return 1
  }

# YSF-Haut-de-France
  if {$cmd == "3007"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sc4fm"
  playMsg "Core" "ysfhdf"
  exec nohup /etc/spotnik/restart.ysf 3007 &
  return 1
  }

# YSF-Linux
  if {$cmd == "3008"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sc4fm"
  playMsg "Core" "ysflinux"
  exec nohup /etc/spotnik/restart.ysf 3008 &
  return 1
  }

# YSF-Test
  if {$cmd == "3009"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sc4fm"
  playMsg "Core" "ysftest"
  exec nohup /etc/spotnik/restart.ysf 3009 &
  return 1
  }

# YSF-FraWide
  if {$cmd == "3010"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sc4fm"
  playMsg "Core" "ysffrawide"
  exec nohup /etc/spotnik/restart.ysf 3010 &
  return 1
  }

# YSF-Emcom
  if {$cmd == "3012"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sc4fm"
  playMsg "Core" "encom"
  exec nohup /etc/spotnik/restart.ysf 3012 &
  return 1
  }

# YSF-NANTES
  if {$cmd == "3044"} {
	playMsg "Core" "activating"
  playMsg "Core" "Sc4fm"
  playMsg "Core" "ysfnantes"
  exec nohup /etc/spotnik/restart.ysf 3044 &
  return 1
  }

# YSF-WireX
  if {$cmd == "3090"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sc4fm"
  playMsg "Core" "ysfwirex"
  exec nohup /etc/spotnik/restart.ysf 3090 &
  return 1
  }

# YSF-FON
  if {$cmd == "3097"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sc4fm"
  playMsg "Core" "Sfon"
  exec nohup /etc/spotnik/restart.ysf 3097 &
  return 1
  }

# YSF-INTERNATIONAL-RRF
  if {$cmd == "3099"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sc4fm"
  playMsg "Core" "interrrf"
  exec nohup /etc/spotnik/restart.ysf 3099 &
  return 1
  }

### MODE NUMERIQUE DMR ###

# DMR-208
  if {$cmd == "208"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sdmr"
  playMsg "Core" "Tgdmr"
  playNumber 208; 
  exec nohup /etc/spotnik/restart.dmr 208 & 
  return 1
  }

# DMR-647
  if {$cmd == "647"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sdmr"
  playMsg "Core" "Tgdmr"
  playNumber 647;
  exec nohup /etc/spotnik/restart.dmr 647 & 
  return 1
  }


# DMR-2080
  if {$cmd == "2080"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sdmr"
  playMsg "Core" "Tgdmr"
  playNumber 208;
  playNumber 0 ;
  exec nohup /etc/spotnik/restart.dmr 2080 & 
  return 1
  }


# DRM-2081
  if {$cmd == "2081"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sdmr"
  playMsg "Core" "Tgdmr"
  playNumber 208;
  playNumber 1;  
  exec nohup /etc/spotnik/restart.dmr 2081 & 
  return 1
  }

# DMR-2082
  if {$cmd == "2082"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sdmr"
  playMsg "Core" "Tgdmr"
  playNumber 208;
  playNumber 2;  
  exec nohup /etc/spotnik/restart.dmr 2082 & 
  return 1
  }

# DRM-2083
  if {$cmd == "2083"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sdmr"
  playMsg "Core" "Tgdmr"
  playNumber 208;
  playNumber 3;  	
  exec nohup /etc/spotnik/restart.dmr 2083 & 
  return 1
  }

# DMR-2084
  if {$cmd == "2084"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sdmr"
  playMsg "Core" "Tgdmr"
  playNumber 208;
  playNumber 4;	
  exec nohup /etc/spotnik/restart.dmr 2084 & 
  return 1
  }

# DRM-2085
  if {$cmd == "2085"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sdmr"
  playMsg "Core" "Tgdmr"
  playNumber 208;
  playNumber 5;  
  exec nohup /etc/spotnik/restart.dmr 2085 & 
  return 1
  }


# DMR-20825
  if {$cmd == "20825"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sdmr"
  playMsg "Core" "Tgdmr"
  playNumber 208;
  playNumber 25;	
  exec nohup /etc/spotnik/restart.dmr 20825 & 
  return 1
  }

# DMR-20854
  if {$cmd == "20854"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sdmr"
  playMsg "Core" "Tgdmr"
  playNumber 208;
  playNumber 54; 
  exec nohup /etc/spotnik/restart.dmr 20854 & 
  return 1
  }

# DMR-20844
  if {$cmd == "20844"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sdmr"
  playMsg "Core" "Tgdmr"
  playNumber 208;
  playNumber 44;	
  exec nohup /etc/spotnik/restart.dmr 20844 & 
  return 1
  }

# DMR-20867
  if {$cmd == "20867"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sdmr"
  playMsg "Core" "Tgdmr"
  playNumber 208;
  playNumber 67;
  exec nohup /etc/spotnik/restart.dmr 20867 & 
  return 1
  }

### DMR-9990 PERROQUET
  if {$cmd == "888"} {
  playMsg "Core" "activating"
  playMsg "Core" "Sdmr"
  playMsg "Core" "parrot"	
  exec nohup /etc/spotnik/restart.dmr 9990 & 
  return 1
  }
 
# 1000 Reboot

  if {$cmd == "1000"} {
    puts "Executing external command"
    playMsg "Core" "online"
    exec reboot 
    return 1
  }

# 1001 halt

  if {$cmd == "1001"} {
    puts "Executing external command"
    playMsg "Core" "online"
    exec halt 
    return 1
  }

  return 0
}


#
# Executed once every whole minute. Don't put any code here directly
# Create a new function and add it to the timer tick subscriber list
# by using the function addMinuteTickSubscriber.
#
proc every_minute {} {
  variable minute_tick_subscribers;
  #puts [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"];
  foreach subscriber $minute_tick_subscribers {
    $subscriber;
  }
}


#
# Executed once every whole minute. Don't put any code here directly
# Create a new function and add it to the timer tick subscriber list
# by using the function addSecondTickSubscriber.
#
proc every_second {} {
  variable second_tick_subscribers;
  #puts [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"];
  foreach subscriber $second_tick_subscribers {
    $subscriber;
  }
}


#
# Deprecated: Use the addMinuteTickSubscriber function instead
#
proc addTimerTickSubscriber {func} {
  puts "*** WARNING: Calling deprecated TCL event handler addTimerTickSubcriber."
  puts "             Use addMinuteTickSubscriber instead"
  addMinuteTickSubscriber $func;
}


#
# Use this function to add a function to the list of functions that
# should be executed once every whole minute. This is not an event
# function but rather a management function.
#
proc addMinuteTickSubscriber {func} {
  variable minute_tick_subscribers;
  lappend minute_tick_subscribers $func;
}


#
# Use this function to add a function to the list of functions that
# should be executed once every second. This is not an event
# function but rather a management function.
#
proc addSecondTickSubscriber {func} {
  variable second_tick_subscribers;
  lappend second_tick_subscribers $func;
}


#
# Should be executed once every whole minute to check if it is time to
# identify. Not exactly an event function. This function handle the
# identification logic and call the send_short_ident or send_long_ident
# functions when it is time to identify.
#
proc checkPeriodicIdentify {} {
  variable prev_ident;
  variable short_ident_interval;
  variable long_ident_interval;
  variable min_time_between_ident;
  variable ident_only_after_tx;
  variable need_ident;
  global logic_name;

  if {$short_ident_interval == 0} {
    return;
  }

  set now [clock seconds];
  set hour [clock format $now -format "%k"];
  regexp {([1-5]?\d)$} [clock format $now -format "%M"] -> minute;

  set short_ident_now \
      	    [expr {($hour * 60 + $minute) % $short_ident_interval == 0}];
  set long_ident_now 0;
  if {$long_ident_interval != 0} {
    set long_ident_now \
      	    [expr {($hour * 60 + $minute) % $long_ident_interval == 0}];
  }

  if {$long_ident_now} {
    puts "$logic_name: Sending long identification...";
    send_long_ident $hour $minute;
    set prev_ident $now;
    set need_ident 0;
  } else {
    if {$now - $prev_ident < $min_time_between_ident} {
      return;
    }
    if {$ident_only_after_tx && !$need_ident} {
      return;
    }

    if {$short_ident_now} {
      puts "$logic_name: Sending short identification...";
      send_short_ident $hour $minute;
      set prev_ident $now;
      set need_ident 0;
    }
  }
}


#
# Executed when the QSO recorder is being activated
#
proc activating_qso_recorder {} {
  playMsg "Core" "activating";
  playMsg "Core" "qso_recorder";
}


#
# Executed when the QSO recorder is being deactivated
#
proc deactivating_qso_recorder {} {
  playMsg "Core" "deactivating";
  playMsg "Core" "qso_recorder";
}


#
# Executed when trying to deactivate the QSO recorder even though it's
# not active
#
proc qso_recorder_not_active {} {
  playMsg "Core" "qso_recorder";
  playMsg "Core" "not_active";
}


#
# Executed when trying to activate the QSO recorder even though it's
# already active
#
proc qso_recorder_already_active {} {
  playMsg "Core" "qso_recorder";
  playMsg "Core" "already_active";
}


#
# Executed when the timeout kicks in to activate the QSO recorder
#
proc qso_recorder_timeout_activate {} {
  playMsg "Core" "timeout"
  playMsg "Core" "activating";
  playMsg "Core" "qso_recorder";
}


#
# Executed when the timeout kicks in to deactivate the QSO recorder
#
proc qso_recorder_timeout_deactivate {} {
  playMsg "Core" "timeout"
  playMsg "Core" "deactivating";
  playMsg "Core" "qso_recorder";
}


#
# Executed when the user is requesting a language change
#
proc set_language {lang_code} {
  global logic_name;
  puts "$logic_name: Setting language $lang_code (NOT IMPLEMENTED)";

}


#
# Executed when the user requests a list of available languages
#
proc list_languages {} {
  global logic_name;
  puts "$logic_name: Available languages: (NOT IMPLEMENTED)";

}


#
# Executed when the node is being brought online or offline
#
proc logic_online {online} {
  global mycall
  variable CFG_TYPE

  if {$online} {
    playMsg "Core" "online";
    spellWord $mycall;
    if {$CFG_TYPE == "Repeater"} {
      playMsg "Core" "repeater";
    }
  }
}


##############################################################################
#
# Main program
#
##############################################################################

if [info exists CFG_SHORT_IDENT_INTERVAL] {
  if {$CFG_SHORT_IDENT_INTERVAL > 0} {
    set short_ident_interval $CFG_SHORT_IDENT_INTERVAL;
  }
}

if [info exists CFG_LONG_IDENT_INTERVAL] {
  if {$CFG_LONG_IDENT_INTERVAL > 0} {
    set long_ident_interval $CFG_LONG_IDENT_INTERVAL;
    if {$short_ident_interval == 0} {
      set short_ident_interval $long_ident_interval;
    }
  }
}

if [info exists CFG_IDENT_ONLY_AFTER_TX] {
  if {$CFG_IDENT_ONLY_AFTER_TX > 0} {
    set ident_only_after_tx $CFG_IDENT_ONLY_AFTER_TX;
  }
}

if [info exists CFG_SHORT_ANNOUNCE_ENABLE] {
  set short_announce_enable $CFG_SHORT_ANNOUNCE_ENABLE
}

if [info exists CFG_SHORT_ANNOUNCE_FILE] {
  set short_announce_file $CFG_SHORT_ANNOUNCE_FILE
}

if [info exists CFG_SHORT_VOICE_ID_ENABLE] {
  set short_voice_id_enable $CFG_SHORT_VOICE_ID_ENABLE
}

if [info exists CFG_SHORT_CW_ID_ENABLE] {
  set short_cw_id_enable $CFG_SHORT_CW_ID_ENABLE
}

if [info exists CFG_LONG_ANNOUNCE_ENABLE] {
  set long_announce_enable $CFG_LONG_ANNOUNCE_ENABLE
}

if [info exists CFG_LONG_ANNOUNCE_FILE] {
  set long_announce_file $CFG_LONG_ANNOUNCE_FILE
}

if [info exists CFG_LONG_VOICE_ID_ENABLE] {
  set long_voice_id_enable $CFG_LONG_VOICE_ID_ENABLE
}

if [info exists CFG_LONG_CW_ID_ENABLE] {
  set long_cw_id_enable $CFG_LONG_CW_ID_ENABLE
}


# end of namespace
}

#
# This file has not been truncated
#
