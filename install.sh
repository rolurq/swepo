#!/bin/bash

if [ $(whoami) != "root" ]; then
    sudo $0
    exit
fi

cp swepo.sh /usr/bin/swepo
