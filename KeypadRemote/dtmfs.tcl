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
