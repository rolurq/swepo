#!/bin/bash

if [ $(whoami) != "root" ]; then
    sudo $0 $@
    exit
fi

SOURCES="/etc/apt"

if [ ! -d $SOURCES/sources.list.d ]; then
    mkdir $SOURCES/sources.list.d
    echo "put your alternative sources in /etc/apt/sources.list.d"
    exit 1
fi

if [ -a $SOURCES/sources.list ]; then
    mv $SOURCES/sources.list $SOURCES/sources.list.disabled
fi

if [ $# == 0 ]; then
    mv "$SOURCES/sources.list.disabled" "$SOURCES/sources.list"
fi

ACTION=enable

while true ; do
    case "$1" in
        # set the state acording to the current option
        -c|--config) ACTION=config ; shift ;;
        "") break ;;  # no more arguments
        *)
            case $ACTION in
                config)
                    edit $SOURCES/sources.list.d/$1.list* ;
                    if [ $? != 0 ] ; then
                        echo "Error editing!" ; exit 1 ; fi ;
                    shift ;;
                *) break ;;
            esac
            if [ $? != 0 ] ; then break ; fi ;;
    esac
done

# disable all sources list
shopt -s nullglob
for source in $SOURCES/sources.list.d/*.list; do
    mv "$source" "${source}.disabled"
done

for name; do
    mv "$SOURCES/sources.list.d/$name.list.disabled" \
       "$SOURCES/sources.list.d/$name.list"  # enable the desired sources
done
