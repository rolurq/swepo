_swepo() {
    local cur opts

    # get sources names until first '.'
    opts=`ls /etc/apt/sources.list.d | cut -d . -f 1`
    cur="${COMP_WORDS[COMP_CWORD]}"  # update completion word

    # generate completion list
    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )

    return 0
}
complete -F _swepo swepo  # complete using _swepo function
