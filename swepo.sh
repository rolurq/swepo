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

declare -A LIST_FILES
for source in `ls $SOURCES/*.list* | cut -d / -f 5 | cut -d . -f 1`; do
  LIST_FILES[$source]=disable ;
done

ACTION=enable

while true ; do
    case "$1" in
        # set the state acording to the current option
        -d|--disable) ACTION=disable ; shift ;;
        -e|--enable) ACTION=enable ; shift ;;
        -a|--add) ACTION=add ; shift ;;
        -r|--remove) ACTION=remove ; shift ;;
        -c|--config) ACTION=config ; shift ;;
        "") break ;;  # no more arguments
        *)
            # control opposite actions
            # add, remove and config doesn't cause trouble
            case $ACTION in
                add)
                    # create the file
                    # if the file is already created then it will just edit
                    touch $SOURCES/sources.list.d/$source.list ;
                    edit $SOURCES/sources.list.d/$source.list ;;
                remove)
                    # remove the correct file in one of the two calls
                    rm $SOURCES/sources.list.d/$source.list 2> /dev/null ;
                    rm $SOURCES/sources.list.d/$source.list.disabled 2> /dev/null ;;
                config)
                    edit $SOURCES/sources.list.d/$source.list* ;
                    if [ $? != 0 ] ; then
                        echo "Error editing!" ; exit 1 ; fi ;;
                esac ;
            # store the action asociated with each file
            # prevents multiple actions in one file
            FILES=($FILES $1) ; LIST_FILES[$1]=$ACTION ; shift ;;
    esac
done

# execute the action for each file
for source in $FILES; do
    case ${LIST_FILES[$source]} in
        disable)
            # disable if is not
            if [ -a $SOURCES/sources.list.d/$source.list ] ; then
                mv $SOURCES/sources.list.d/$source.list \
                   $SOURCES/sources.list.d/$source.list.disabled ;
            fi ;;
        enable)
            # enable if is not
            if [ -a $SOURCES/sources.list.d/$source.list.disabled ] ; then
                mv $SOURCES/sources.list.d/$source.list.disabled \
                   $SOURCES/sources.list.d/$source.list ;
            fi ;;
    esac ;
done

