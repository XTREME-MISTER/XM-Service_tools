#!/usr/bin/bash
UPDATE_ALL_IS_RUNNING=`ps|grep /update_all.sh|grep -v grep|wc -c`
if [[ ${UPDATE_ALL_IS_RUNNING} -eq 0 ]]; then
  if [[ `cat /media/fat/MiSTer.ini|grep fb_terminal=1|wc -c` -eq 0 ]]; then 
    echo "#### MiSTerScriptLauncher: fb_terminal=0 case => Ressetting MiSTer and disable 'dialog' for 5 seconds"
    /media/fat/xmsl/mbc raw_seq {64{38{1D{2A}64}38}1D}2A; sleep 1; chmod 644 /usr/bin/dialog
    killall MiSTer
    /media/fat/xmsl/MiSTerScriptLauncher /media/fat/Scripts/update_all.sh&
    sleep 5;chmod 755 /usr/bin/dialog
    echo "#### MiSTerScriptLauncher: dialog permissions were restored!"
  else 
	chmod 755 /usr/bin/dialog
    echo "#### MiSTerScriptLauncher: fb_terminal=1 case"
    /media/fat/xmsl/mbc raw_seq {64{38{1D{2A}64}38}1D}2A 
    echo "#### MiSTerScriptLauncher: MiSTer reset completed... waiting 1s"
    sleep 1
    echo "#### MiSTerScriptLauncher: Launching update_all script"
    killall MiSTer
    /media/fat/xmsl/MiSTerScriptLauncher /media/fat/Scripts/update_all.sh&
  fi
else
  echo "#### MiSTerScriptLauncher: update_all is currently running => Aborting"
fi