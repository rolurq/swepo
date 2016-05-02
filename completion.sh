_swepo() {
    local cur opts
    _init_completion || return

    # get sources names until first '.'
    opts=`ls /etc/apt/sources.list.d | cut -d . -f 1`
    cur="${COMP_WORDS[COMP_CWORD]}"  # update completion word

    # generate completion list
    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $( compgen -W '-a --add -c --config
          -d --disable -e --enable -r --remove -t --toggle' \
          -- ${cur} ) )
    else
        COMPREPLY=( $( compgen -W "${opts}" -- ${cur} ) )
    fi

    return 0
}
complete -F _swepo swepo  # complete using _swepo function
