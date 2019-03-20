#!/bin/bash

local=$(echo $3)
if [ -f ${local} ]; then
  rm ${local}
fi
file=$(echo $1)
phone=$(echo $2)

pid=$(ps aux | grep auto.calls.sh | grep -v grep | head -1 |awk '{print $2}')
while [ ${pid} ];
do 
  pid=$(ps aux | grep auto.calls.sh | grep -v grep | head -1 |awk '{print $2}')
  #echo ${file} - ${phone} 
  tail -f ${file}| grep --line-buffered ${phone} >> ${local}
done
exit
