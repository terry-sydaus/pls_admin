#!/bin/bash

number_of_processes=$(ps aux | grep scheduler | wc -l)
#echo $number_of_processes

if [[ "$number_of_processes" = 1 ]]; then
  /bin/date >> /home/terry/pls_admin/check_sched.txt
  echo "Need to start the scheduler" >> /home/terry/pls_admin/check_sched.txt
  /usr/bin/docker exec -d adminpls python3 -m flask scheduler 
  exit 1
fi
