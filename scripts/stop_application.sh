#!/bin/bash

set -e

# ps -ef | grep tomcat10.0.8 | grep -v grep
[ $?  -eq "0" ] && echo "process is running" && service tomcat stop|| echo "process is not running"
