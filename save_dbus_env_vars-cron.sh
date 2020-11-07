#!/bin/bash
echo 'export' $(env | grep DBUS_SESSION_BUS_ADDRESS) > $HOME/.Xdbus
echo 'export' $(env | grep XAUTHORITY) >> $HOME/.Xdbus
echo 'export' $(env | grep DISPLAY) >> $HOME/.Xdbus

