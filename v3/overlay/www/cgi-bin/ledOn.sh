#!/bin/sh

echo "Content-type: text/html";
echo ""
echo "`echo "0" > /sys/class/gpio/gpio18/value`"
