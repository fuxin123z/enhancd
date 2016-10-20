__enhancd::arguments::option()
{
    local opt="$1" action
    shift

    cat "$ENHANCD_ROOT/src/custom/config.ltsv" \
        | awk '/:'$opt'\t/{print $4}' \
        | read action

    if [[ -z $action ]]; then
        __enhancd::utils::die \
            "$opt: no such option\n"
        return 1
    fi

    if __enhancd::utils::has __enhancd::custom::sources::$action; then
        __enhancd::custom::sources::$action "$@"
    elif __enhancd::utils::has __enhancd::custom::options::$action; then
        __enhancd::custom::options::$action "$@"
    else
        __enhancd::utils::die "$action: no such action defined\n"
        return 1
    fi
}

__enhancd::arguments::hyphen()
{
    if [[ $ENHANCD_DISABLE_HYPHEN == 1 ]]; then
        echo "$OLDPWD"
        return 0
    fi

    __enhancd::history::list "$1" | head | __enhancd::history::filter
}

__enhancd::arguments::dot()
{
    if [[ $ENHANCD_DISABLE_DOT == 1 ]]; then
        echo ".."
        return 0
    fi

    __enhancd::path::go_upstairs "$PWD" \
        | __enhancd::utils::reverse \
        | __enhancd::utils::grep "$1" \
        | __enhancd::history::filter \
        | __enhancd::path::to_abspath

    # Returns false if __enhancd::path::to_abspath fails
    # __enhancd::path::to_abspath returns false
    # if __enhancd::history::filter doesn't output anything
    if [[ $? -eq 1 ]]; then
        if [[ -n $1 ]]; then
            # Returns false if an argument is given
            return $_ENHANCD_FAILURE
        else
            # Returns true when detecting to press Ctrl-C in selection
            return $_ENHANCD_SUCCESS
        fi
    fi
}

__enhancd::arguments::none()
{
    if [[ "$ENHANCD_DISABLE_HOME" == 1 ]]; then
        echo "$HOME"
        return 0
    fi

    __enhancd::history::list --home | __enhancd::history::filter
}

__enhancd::arguments::given()
{
    if [[ -d $1 ]]; then
        echo "$1"
        return 0
    fi

    __enhancd::history::list "$1" | __enhancd::history::filter
}