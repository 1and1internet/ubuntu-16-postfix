#!/bin/bash
# Simple while loop to get log rotate working
while true
do
  sleep 12h
  /usr/sbin/logrotate -f /etc/logrotate.d/logrotate
done
