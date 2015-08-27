#!/bin/bash

if [ $(whoami) != "root" ]
then
    sudo "$0"
    exit
fi 
