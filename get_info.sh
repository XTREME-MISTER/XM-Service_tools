#!/bin/sh
out="{ "

LAST_RELEASE_FILE=/media/fat/xmsl/.last_release
if [ -f ${LAST_RELEASE_FILE} ]; then
  LOCAL_LAST_RELEASE=`cat /media/fat/xmsl/.last_release | wc -c`
  if [[ ${LOCAL_LAST_RELEASE} -eq 0 ]]; then
    out="${out} \"local_last_release_status\":\"ERROR: The XMSL service version is wrong or missing. Please restore the /media/fat/xmsl folder files manually, or burn the latest Mr.Fusion backup (with XM optimizations) into your MicroSD card. Next retry this option to upgrade to the latest version.\""
    out="${out}, \"local_last_release\":\"None\""
  else
    LOCAL_LAST_RELEASE=`cat /media/fat/xmsl/.last_release|awk '{print $0}'`
    out="${out} \"local_last_release_status\":\"The local XMSL service ${LOCAL_LAST_RELEASE} version is present.\""
    out="${out}, \"local_last_release\":\"${LOCAL_LAST_RELEASE}\""
  fi
else
  out="${out} \"local_last_release_status\":\"ERROR: The XMSL service version is missing. Please restore the /media/fat/xmsl folder files manually, or burn the latest Mr.Fusion backup (with XM optimizations) into your MicroSD card. Next retry this option to upgrade to the latest version.\""
  out="${out}, \"local_last_release\":\"None\""
fi


repo_owner="XTREME-MISTER"
repo_name="XM-Service_tools"
api_url="https://api.github.com/repos/$repo_owner/$repo_name/releases/latest"
remote_release_info=`wget -qO- "$api_url"`
REMOTE_LAST_RELEASE=`echo "$remote_release_info" | jq -r .tag_name | wc -c`
if [[ ${REMOTE_LAST_RELEASE} -eq 0 ]]; then
  out="${out}, \"remote_last_release_status\":\"ERROR: The remote XMSL service version cannot be retrieved. Please check your XM is connected to the Internet and with a valid IP and try again.\""
  out="${out}, \"remote_last_release\":\"None\""
else
  REMOTE_LAST_RELEASE=`echo "$remote_release_info" | jq -r .tag_name`
  out="${out}, \"remote_last_release_status\":\"The latest remote XMSL service version is ${REMOTE_LAST_RELEASE}.\""
  out="${out}, \"remote_last_release\":\"${REMOTE_LAST_RELEASE}\""
fi


TIMEZONE_FILE=/media/fat/linux/timezone
if [ -f ${TIMEZONE_FILE} ]; then
  out="${out}, \"custom_timezone\":true"
else
  out="${out}, \"custom_timezone\":false"
fi


CURRENT_DATE_TIME=`date`
out="${out}, \"current_date_time\":\"$CURRENT_DATE_TIME\""


CURRENT_TIMEZONE=`cat /etc/timezone`
out="${out}, \"current_timezone\":\"$CURRENT_TIMEZONE\""


UBOOT_FILE=/media/fat/linux/u-boot.txt
if [ -f ${UBOOT_FILE} ]; then
  out="${out}, \"uboot_file_exists\":true"

  USB_1MS_FAST_POLLING_ENABLED1=`cat /media/fat/linux/u-boot.txt |grep "usbhid.jspoll=1" | wc -c`
  USB_1MS_FAST_POLLING_ENABLED2=`cat /media/fat/linux/u-boot.txt |grep "xpad.cpol=1" | wc -c`
  if [[ ${USB_1MS_FAST_POLLING_ENABLED1} -eq 0 ]] && [[ ${USB_1MS_FAST_POLLING_ENABLED2} -eq 0 ]]; then
    out="${out}, \"usb_1ms_fast_polling_enabled\":false"
  else
    out="${out}, \"usb_1ms_fast_polling_enabled\":true"
  fi
else
  out="${out}, \"uboot_file_exists\":false"
  out="${out}, \"usb_1ms_fast_polling_enabled\":false"
fi


ETH0_INET=`ifconfig eth0|grep inet | wc -c`
if [[ ${ETH0_INET} -eq 0 ]]; then
  out="${out}, \"eth0_inet\":\"Not connected.\""
else
  ETH0_INET=`ifconfig eth0|grep inet|awk '{print $2}'`
  out="${out}, \"eth0_inet\":\"${ETH0_INET}\""
fi

ETH0_NETMASK=`ifconfig eth0|grep inet | wc -c`
if [[ ${ETH0_NETMASK} -eq 0 ]]; then
  out="${out}, \"eth0_netmask\":\"Not connected.\""
else
  ETH0_NETMASK=`ifconfig eth0|grep inet|awk '{print $4}'`
  out="${out}, \"eth0_netmask\":\"${ETH0_NETMASK}\""
fi

ETH0_MAC=`ifconfig eth0|grep ether | wc -c`
if [[ ${ETH0_MAC} -eq 0 ]]; then
  out="${out}, \"eth0_mac\":\"INTERNAL ERROR: Not eth0 MAC can be parsed.\""
else
  ETH0_MAC=`ifconfig eth0|grep ether|awk '{print toupper($2)}'`
  out="${out}, \"eth0_mac\":\"${ETH0_MAC}\""
fi


WLAN0_PRESENT=`ifconfig |grep wlan0 | wc -c`
if [[ ${WLAN0_PRESENT} -eq 0 ]]; then
  out="${out}, \"wlan0_inet\":\"Not WiFi dongle detected.\""
  out="${out}, \"wlan0_netmask\":\"Not WiFi dongle detected.\""
  out="${out}, \"wlan0_mac\":\"Not WiFi dongle detected.\""
else
  WLAN0_INET=`ifconfig wlan0|grep inet | wc -c`
  if [[ ${WLAN0_INET} -eq 0 ]]; then
    out="${out}, \"wlan0_inet\":\"Not connected.\""
  else
    WLAN0_INET=`ifconfig wlan0|grep inet|awk '{print $2}'`
    out="${out}, \"wlan0_inet\":\"${WLAN0_INET}\""
  fi

  WLAN0_NETMASK=`ifconfig wlan0|grep inet | wc -c`
  if [[ ${WLAN0_NETMASK} -eq 0 ]]; then
    out="${out}, \"wlan0_netmask\":\"Not connected.\""
  else
    WLAN0_NETMASK=`ifconfig wlan0|grep inet|awk '{print $4}'`
    out="${out}, \"wlan0_netmask\":\"${WLAN0_NETMASK}\""
  fi

  WLAN0_MAC=`ifconfig wlan0|grep ether | wc -c`
  if [[ ${WLAN0_MAC} -eq 0 ]]; then
    out="${out}, \"wlan0_mac\":\"INTERNAL ERROR: Not MAC address found on wlan0 interface.\""
  else
    WLAN0_MAC=`ifconfig wlan0|grep ether|awk '{print toupper($2)}'`
    out="${out}, \"wlan0_mac\":\"${WLAN0_MAC}\""
  fi
fi


BLE_PRESENT=`hciconfig |grep hci0 | wc -c`
if [[ ${BLE_PRESENT} -eq 0 ]]; then
  out="${out}, \"ble_mac\":\"Not BLE dongle detected.\""
else
  BLE_MAC=`hciconfig hci0 |grep "BD Address" |awk '{print $3}'`
  out="${out}, \"ble_mac\":\"${BLE_MAC}\""
fi


RTC_PRESENT=`dmesg |grep -E '^.*?(rtc-pcf8563).*?(registered as rtc0).*?$' | wc -c`
if [[ ${RTC_PRESENT} -eq 0 ]]; then
  out="${out}, \"rtc_status\":\"Not RTC add-on board found\""
else
  RTC_PRESENT=`dmesg |grep -E '^.*?(rtc-pcf8563).*?(setting system clock to).*?$' | wc -c`
  if [[ ${RTC_PRESENT} -eq 0 ]]; then
    out="${out}, \"rtc_status\":\"WARNING: RTC present but date/time not set from RTC. Connect the XM to the network, wait for a date update by NTP and run \\\"hwclock -wu\\\" and restart to double check. If the problem persists, verify the CR2032 3V coin battery.\""
  else
    out="${out}, \"rtc_status\":\"OK: Present and date/time updated from RTC\""
  fi
fi


I2C_TEMP1=`i2cget -y 2 0x48 2>&1 |grep -v 'Error:' | wc -c`
if [[ ${I2C_TEMP1} -eq 0 ]]; then
  out="${out}, \"i2c_temp1\":\"ERROR reading temp sensor embedded on RTC board: Review RTC+Temp add-on board.\""
else
  aux=`i2cget -y 2 0x48 |awk '{print toupper($0)}'|sed -e 's/^0X//'`; I2C_TEMP1=`echo "obase=10; ibase=16; $aux" |bc`
  out="${out}, \"i2c_temp1\":\"${I2C_TEMP1}°C\""
fi

I2C_TEMP2=`i2cget -y 2 0x49 2>&1 |grep -v 'Error:' | wc -c`
if [[ ${I2C_TEMP2} -eq 0 ]]; then
  out="${out}, \"i2c_temp2\":\"ERROR reading temp sensor \\\"1\\\": Review RTC+Temp add-on board and FFC cable to temp sensor \\\"1\\\".\""
else
  aux=`i2cget -y 2 0x49 |awk '{print toupper($0)}'|sed -e 's/^0X//'`; I2C_TEMP2=`echo "obase=10; ibase=16; $aux" |bc`
  out="${out}, \"i2c_temp2\":\"${I2C_TEMP2}°C\""
fi

I2C_TEMP3=`i2cget -y 2 0x4a 2>&1 |grep -v 'Error:' | wc -c`
if [[ ${I2C_TEMP3} -eq 0 ]]; then
  out="${out}, \"i2c_temp3\":\"ERROR reading temp sensor \\\"2\\\": Review RTC+Temp add-on board and FFC cable to temp sensor \\\"2\\\".\""
else
  aux=`i2cget -y 2 0x4a |awk '{print toupper($0)}'|sed -e 's/^0X//'`; I2C_TEMP3=`echo "obase=10; ibase=16; $aux" |bc`
  out="${out}, \"i2c_temp3\":\"${I2C_TEMP3}°C\""
fi


JVS_STATUS1=/media/fat/linux/user-startup.sh
JVS_STATUS2=`cat /media/fat/MiSTer.ini |grep jamma_vid=0x8371 | wc -c`
JVS_STATUS3=`cat /media/fat/MiSTer.ini |grep jamma_pid=0x3551 | wc -c`
JVS_STATUS4=/media/fat/config/inputs/input_8371_3551_v3.map
JVS_STATUS5=/media/fat/de10-jvscore/jvscore
JVS_STATUS6=`ps |grep jvscore | grep -v grep | wc -c`
JVS_STATUS7=/tmp/JVSCORE

if [ -f ${JVS_STATUS1} ]; then
  CURRENT_KEYBOARD_MAP=`cat /media/fat/linux/user-startup.sh |grep loadkeys | wc -c`
  if [[ ${CURRENT_KEYBOARD_MAP} -eq 0 ]]; then
    out="${out}, \"current_keyboard_map\":\"default (ENGLISH)\""
  else
    CURRENT_KEYBOARD_MAP2=`cat /media/fat/linux/user-startup.sh |grep loadkeys | awk '{print $2}'`
    out="${out}, \"current_keyboard_map\":\"${CURRENT_KEYBOARD_MAP2}\""
  fi

  JVS_STATUS1A=`cat /media/fat/linux/user-startup.sh |grep S60jvscore | wc -c`
  if [[ ${JVS_STATUS1A} -eq 0 ]]; then
    out="${out}, \"jvs_status\":\"ERROR: JVSCore autostart config is missing.\""
  else
    if [[ ${JVS_STATUS2} -eq 0 ]]; then
      out="${out}, \"jvs_status\":\"ERROR: JVSCore USB VID settings are missing on MiSTer.ini\""
    else
      if [[ ${JVS_STATUS3} -eq 0 ]]; then
        out="${out}, \"jvs_status\":\"ERROR: JVSCore USB PID settings are missing on MiSTer.ini\""
      else
        if [ -f ${JVS_STATUS4} ]; then
          if [ -f ${JVS_STATUS5} ]; then
            if [[ ${JVS_STATUS6} -eq 0 ]]; then
              out="${out}, \"jvs_status\":\"ERROR: JVSCore process is not running or has crashed: Check JVS-B1 dongle, JVS \\\"USB\\\" cable and JVS IO board power => Reboot MiSTer to try again.\""
            else
              if [ -f ${JVS_STATUS7} ]; then
                JVS_STATUS7A=`cat /tmp/JVSCORE`
	        out="${out}, \"jvs_status\":\"OK: JVSCore running & connected to the '${JVS_STATUS7A}' board.\""
              else
	        out="${out}, \"jvs_status\":\"WARNING: JVSCore process is running but not JVS IO board information was found: Upgrade JVSCore to the latest version.\""
              fi
            fi
          else
            out="${out}, \"jvs_status\":\"ERROR: JVSCore not installed.\""
          fi
        else
          out="${out}, \"jvs_status\":\"ERROR: JVSCore input map file is missing.\""
        fi
      fi
    fi
  fi
else
  out="${out}, \"current_keyboard_map\":\"default (ENGLISH)\""
  out="${out}, \"jvs_status\":\"ERROR: JVSCore autostart config and user-startup.sh are missing.\""
fi


MEDIA_FAT_PRESENT=`df -h|grep /media/fat | wc -c`
if [[ ${MEDIA_FAT_PRESENT} -eq 0 ]]; then
  out="${out}, \"media_fat_size\":\"ERROR: Not /media/fat mount point detected.\""
  out="${out}, \"media_fat_used\":\"ERROR: Not /media/fat mount point detected.\""
  out="${out}, \"media_fat_avail\":\"ERROR: Not /media/fat mount point detected.\""
else
  MEDIA_FAT_SIZE=`df -h|grep /media/fat |awk '{print $2}'`
  out="${out}, \"media_fat_size\":\"${MEDIA_FAT_SIZE}\""
  MEDIA_FAT_USED=`df -h|grep /media/fat |awk '{print $3" "$5}'`
  out="${out}, \"media_fat_used\":\"${MEDIA_FAT_USED}\""
  MEDIA_FAT_AVAIL=`df -h|grep /media/fat |awk '{print $4}'`
  out="${out}, \"media_fat_avail\":\"${MEDIA_FAT_AVAIL}\""
fi


MEDIA_USB0_PRESENT=`df -h|grep /media/usb0 | wc -c`
if [[ ${MEDIA_USB0_PRESENT} -eq 0 ]]; then
  out="${out}, \"media_usb0_size\":\"Not /media/usb0 mount point detected. Not external HDD or embedded M.2 SSD SATA disk connected or well formated.\""
  out="${out}, \"media_usb0_used\":\"Not /media/usb0 mount point detected. Not external HDD or embedded M.2 SSD SATA disk connected or well formated.\""
  out="${out}, \"media_usb0_avail\":\"Not /media/usb0 mount point detected. Not external HDD or embedded M.2 SSD SATA disk connected or well formated.\""
else
  MEDIA_USB0_SIZE=`df -h|grep /media/usb0 |awk '{print $2}'`
  out="${out}, \"media_usb0_size\":\"${MEDIA_USB0_SIZE}\""
  MEDIA_USB0_USED=`df -h|grep /media/usb0 |awk '{print $3" "$5}'`
  out="${out}, \"media_usb0_used\":\"${MEDIA_USB0_USED}\""
  MEDIA_USB0_AVAIL=`df -h|grep /media/usb0 |awk '{print $4}'`
  out="${out}, \"media_usb0_avail\":\"${MEDIA_USB0_AVAIL}\""
fi


out="${out} }"

echo $out
