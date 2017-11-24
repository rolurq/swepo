#!/bin/bash

# configuration
SOURCES="/etc/apt"
SOURCES_D="sources.list.d"

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

status_str=''

declare -A LIST_FILES
for source in `ls $SOURCES/$SOURCES_D/*.list* | cut -d / -f 5`; do
  name=`echo $source | cut -d . -f 1`
  if [ $# == 0 ]; then
    echo $source | grep -q "\.list$"
    if [ $? -eq 0 ]; then
      _status="\e[0;1;32menabled\e[0;0m"
    else
      _status="\e[0;1;31mdisabled\e[0;0m"
    fi
    status_str=${status_str}'\n'${name}'\t'${_status}
  else
    FILES="$name $FILES"
    LIST_FILES[$name]=none ;
  fi
done

# print formatted table
echo -e ${status_str} | column -t

if [ $# == 0 ]; then exit 0; fi

if [ $(whoami) != "root" ]; then
  sudo $0 $@
  exit
fi

# check for sources.list.d directory
if [ ! -d $SOURCES/$SOURCES_D ]; then
  mkdir $SOURCES/$SOURCES_D
  echo "put your alternative sources in $SOURCES/$SOURCES_D/"
  exit 1
fi

ACTION=enable # default action

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
          touch $SOURCES/$SOURCES_D/$1.list ;
          editor $SOURCES/$SOURCES_D/$1.list ;;
        remove)
          # remove the correct file in one of the two calls
          rm $SOURCES/$SOURCES_D/$1.list 2> /dev/null ;
          rm $SOURCES/$SOURCES_D/$1.list.disabled 2> /dev/null ;;
        config)
          editor $SOURCES/$SOURCES_D/$1.list* ;
          if [ $? != 0 ] ; then
            echo "Error editing!" ; exit 1 ; fi ;;
      esac ;
      # store the action asociated with each file
      # prevents multiple actions in one file
      FILES="$1 $FILES" ; LIST_FILES[$1]=$ACTION ;
      shift ;;
  esac
done

# execute the action for each file
for source in $FILES; do
  case ${LIST_FILES[$source]} in
    disable)
      # disable if is not
      if [ -a $SOURCES/$SOURCES_D/$source.list ] ; then
        mv $SOURCES/$SOURCES_D/$source.list \
           $SOURCES/$SOURCES_D/$source.list.disabled ;
      fi ;;
    enable)
      # enable if is not
      if [ -a $SOURCES/$SOURCES_D/$source.list.disabled ] ; then
        mv $SOURCES/$SOURCES_D/$source.list.disabled \
           $SOURCES/$SOURCES_D/$source.list ;
      fi ;;
  esac ;
done

