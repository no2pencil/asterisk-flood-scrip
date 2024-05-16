#!/bin/bash

# Asterisk auto call script
# The purpose is to flood scam call centers
#
# For my buddy Nexus....

function ctrl_c() {
  pid=$(ps aux|grep eval.sh|grep -v grep|awk '{print $2}')
  if [ ${pid} ]; then
    kill -9 ${pid}
  fi
  exit
}

function load_conf() {
  conffile=auto.calls.conf
  Dnum=$(cat ${conffile}|cut -d',' -f1)
  Fnum=$(cat ${conffile}|cut -d',' -f2)
  Burst=$(cat ${conffile}|cut -d',' -f3)
  Pause=$(cat ${conffile}|cut -d',' -f4)
  Rid=$(cat ${conffile}|cut -d',' -f5)
  if [ ${Rid} -eq 0 ]; then
    RidCh="Y"
  else
    RidCh="N"
  fi
  # Other Global Variables...
  wd=$(cat ${conffile}|cut -d',' -f6) 
  outbound=$(cat ${conffile}|cut -d',' -f7)
  logd=$(cat ${conffile}|cut -d',' -f8)
  tlog="/tmp/autolog.txt"
}

function save_conf() {
  conffile=auto.calls.conf
  mv ${conffile} ${conffile}.bak
  echo "${Dnum},${Fnum},${Burst},${Pause},${Rid},${wd},${outbound},${logd}" > ${conffile}
}

function exit_clean() {
  pid=$(ps aux|grep eval.sh|grep -v grep|awk '{print $2}')
  if [ ${pid} ]; then
    kill -9 ${pid}
  fi
  exit 0
}

function menu() {
  clear
  echo "[======================]"
  echo "[      Main Menu       ]"
  echo "[======================]"
  echo "  C) Configure"
  echo "  D) Dial"
  echo "  H) Help"
  echo "  Q) Quit"
  echo "[======================]"
  echo "[    Enter Selection   ]"
  echo "[======================]"
}

function configure() {
  clear
  echo "[======================]"
  echo "[      Conf Menu       ]"
  echo "[======================]"
  echo "  D) Dial ( ${Dnum} )"
  echo "  F) From ( ${Fnum} )"
  echo "  R) Random Caller id [${RidCh}]"
  echo "[----------------------]"
  echo "  B) Burst - ${Burst} Calls"
  echo "  P) Pause - ${Pause} Seconds "
  echo "[----------------------]"
  echo "  L) ReLoad Config"
  echo "  S) Save Config"
  echo "[----------------------]"
  echo "  W) Working Dir ( ${wd} )"
  echo "  O) Output Dir ( ${outbound} ) "
  echo "  V) Log Directory ( ${logd} ) "
  echo "[----------------------]"
  echo "  M) Main Menu"
  echo "[======================]"
  echo "[    Enter Selection   ]"
  echo "[======================]"
}

function dial() {
  umask 222
  trap 'menu; exit_clean' SIGINT SIGQUIT
  while :
  do
    # #################### #
    # Cleanup Previous Run #
    # #################### #
    rm ${wd}*.call 2>/dev/null

    # ################### #
    # Randomize Caller ID #
    # ################### #
    if [ ${Rid} -eq 0 ]; then 
      ### Fetch major area code
      areacode=$(awk -v min=1 -v max=16 '
        BEGIN {
          srand();
          r_number=int( min + rand() * (max - min + 1) )
        } 
        NR == r_number' areacodes.txt)

      Fnum=$(awk -v min=1 -v max=9 '
        BEGIN{
          srand(); 
          print int(min+rand()*(max-min+1))int(min+rand()*(max-min+1))int(min+rand()*(max-min+1))int(min+rand()*(max-min+1))int(min+rand()*(max-min+1))int(min+rand()*(max-min+1))int(min+rand()*(max-min+1))}')
      Fnum=$(echo ${areacode}${Fnum})
    fi
    clear
    loop=0

    # ################# #
    # Create Call Files #
    # ################# #
    while [ ${loop} -lt ${Burst} ]; 
    do
      touch ${wd}${loop}.call
      chown asterisk:wheel ${wd}${loop}.call
      echo "Channel: SIP/flowroute/1${Dnum}" > ${wd}${loop}.call
      echo "Callerid: ${Fnum}" >> ${wd}${loop}.call
      echo "Priority: 1" >> ${wd}${loop}.call
      echo "Context: incoming-calls" >> ${wd}${loop}.call
      echo "Extension: 1003" >> ${wd}${loop}.call
      echo "MaxRetries: 2" >> ${wd}${loop}.call
      echo "RetryTime: 60" >> ${wd}${loop}.call
      loop=$(expr ${loop} + 1)
    done

    # ############################### #
    # Send to Asterisk for Processing #
    # ############################### #
    #set PWD=$(pwd)
    cp -p ${wd}*.call ${outbound} 2>/dev/null
    #cd ${PWD}

    logtxt='0'
    pidtxt=' '
    if [ -f ${tlog} ]; then
      pid=$(ps aux|grep eval.sh|grep -v grep|awk '{print $2}')
      logtxt=$(cat ${tlog}|uniq|wc -l|awk '{print $1}')
    fi
    if [ -z ${pid} ]; then
      pidtxt="Eval Process not running"
    else 
      pidtxt=$(echo ${pid})
    fi 
 
    echo "[======================]"
    echo "[    Ctrl+C to Exit    ]"
    echo "[======================]"
    echo "[ Dialing : ${Dnum} ]"
    echo "[ From    : ${Fnum} ]"
    echo "[======================]"
    echo "${counter} - Calls Placed"
    echo "${logtxt} - Calls Completed [ ${pidtxt} ]"
    counter=$(expr ${counter} + 1)
    trap ctrl_c INT
    sleep ${Pause}
  done
}

function process() {
  case "${Moption}" in
    "C"|"c")
      echo "Configure..."
      Cexit=1
      while [ ${Cexit} -ne 0 ];
      do
        configure 
        read -p "$1"": " Coption
        case "${Coption}" in
          "B"|"b")
            clear
            echo "[======================]"
            echo "[      Set Burst       ]"
            echo "[======================]"
            read -p "$1"": " Burst 
            ;;
          "P"|"p")
            clear
            echo "[======================]"
            echo "[      Set Pause       ]"
            echo "[======================]"
            read -p "$1"": " Pause
            ;;
          "D"|"d")
            clear
            echo "[======================]"
            echo "[      Set Dial        ]"
            echo "[======================]"
            read -p "$1"": " Dnum
            ;;
          "W"|"w")
            clear
            echo "[=======================]"
            echo "[ Set Working Directory ]"
            echo "[=======================]"
            read -p "$1"": " wd
            ;;
          "V"|"v")
            clear
            echo "[============================]"
            echo "[ Set Asterisk Log Directory ]"
            echo "[============================]"
            read -p "$1"": " logd 
            ;;
          "O"|"o")
            clear
            echo "[=============================]"
            echo "[ Set Asterisk Call Directory ]"
            echo "[=============================]"
            read -p "$1"": " outbound
            ;;
          "F"|"f")
            clear
            echo "[======================]"
            echo "[      Set From        ]"
            echo "[======================]"
            read -p "$1"": " Fnum
            ;;
          "R"|"r")
            clear
            echo "[======================]"
            echo "[   Random Caller ID   ]"
            echo "[======================]"
            read -p "(Y)es/(N)o : " RidCh
            if [ "${RidCh}" == "Y" ]; then
              Rid=0
            else
              Rid=1
            fi
            ;;
          "L"|"l")
            load_conf
            ;;
          "S"|"s")
            save_conf
            ;;
          "M"|"m")
            menu
            Cexit=0
            ;;
          *)
            ;;
        esac
      done
      ;;
    "D"|"d")
      dial
      ;;
    "Q"|"q")
      echo "Quit..."
        exit_clean
        ;;
    "H"|"h")
      echo "Help..."
      ;;
    *)
      echo "Fallthrough..."
      ;;
  esac
}

## Initial display
load_conf
menu

pid=$(ps aux|grep eval.sh|grep -v grep|awk '{print $2}')
if [ ${pid} ]; then
  kill -9 ${pid} 
fi

if [ ${logd} ]; then
  if [ ${Dnum} ]; then
    if [ ${tlog} ]; then
      bash eval.sh ${logd} ${Dnum} ${tlog} &
    fi
  fi
fi

while [ 1 -ne 2 ];
do
  counter=0
  read -p "$1"": " Moption
  menu 
  process ${Moption}
done
