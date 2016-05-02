#!/bin/bash

# configuration
SOURCES="/etc/apt"
SOURCES_D="sources.list.d"

if [ $(whoami) != "root" ]; then
    sudo $0 $@
    exit
fi

help() {
  cat << EOF
usage: $0 [[ACTION] [LIST1 LIST2 ...]...]

Each action preceding the list file names will be executed over those
files until another action its specified.

Actions:
  -a, --add      Create new list files
  -c, --config   Edit specified list files
  -d, --disable  Disable list files
  -e, --enable   Enable list files
  -r, --remove   Remove list files
  -t, --toggle   Toggle disabled/enabled to $SOURCES/sources.list.
  This action does not interact with list names

    --help         Show this message

Calling without parameters will show tha available list files ad their
states
EOF
}

declare -A LIST_FILES
for source in `ls $SOURCES/*.list* | cut -d / -f 5 | cut -d . -f 1`; do
  LIST_FILES[$source]=disable ;
done

ACTION=enable
# check for sources.list.d directory
if [ ! -d $SOURCES/$SOURCES_D ]; then
  mkdir $SOURCES/$SOURCES_D
  echo "put your alternative sources in $SOURCES/$SOURCES_D/"
  exit 1
fi


while true ; do
    case "$1" in
        # set the state acording to the current option
        -d|--disable) ACTION=disable ; shift ;;
        -e|--enable) ACTION=enable ; shift ;;
        -a|--add) ACTION=add ; shift ;;
        -r|--remove) ACTION=remove ; shift ;;
        -c|--config) ACTION=config ; shift ;;
    -t|--toggle)
      if [ -a $SOURCES/sources.list ]; then
        mv $SOURCES/sources.list \
           $SOURCES/sources.list.disabled
      else
        mv $SOURCES/sources.list.disabled \
           $SOURCES/sources.list;
      fi
      shift ;;
    -h|--help) help ; exit 0 ;;
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

