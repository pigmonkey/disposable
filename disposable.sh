#!/bin/bash
#
# Launch a disposable application via Firejail.
#
###############################################################################

usage() {
    echo "Usage: disposable.sh [OPTION...]
Launch a disposable application via Firejail.

For further isolation, the sandbox may be launched with a new network
namespace and a restrictive netfilter. Unless otherwise specified, the
first connected interface (as reported by NetworkManager) will be used.

Options:
    -n      create a new network namespace
    -i      specify an ethernet interface for the network (implies -n)
    -d      create a new /dev directory"
}

process_opts() {
    # If requested, activate the network namespace and filter.
    if [[ -n "$network" ]]; then
        # If an interface wasn't specified, get the first connected device.
        if [[ -z "$interface" ]]; then
            interface=`nmcli d | grep -m 1 connected | cut -d ' ' -f 1`
        fi
        netopt="--net=$interface --netfilter"
    fi

    # If requested, create a new /dev directory.
    if [ "$dev" = true  ]; then
        devopt="--private-dev"
    fi
}

app_opts() {
    # If the application is Chromium or Google Chrome, prevent the first run
    # greeting and disable the default browser check.
    case $app in
       "chromium"|"google-chrome")
            appopt="--no-first-run --no-default-browser-check"
            ;;
    esac
}

while getopts "i:dnh" opt; do
    case $opt in
        i)
            interface=$OPTARG
            network=true
            ;;
        n)
            network=true
            ;;
        d)
            dev=true
            ;;
        h)
            usage
            exit
            ;;
        :)
            echo "Option -$OPTARG requires an argument.
            "
            usage
            exit
            ;;
    esac
done

# Process the given options.
process_opts

# Remove the processed options from the arguments.
shift "$((OPTIND - 1))"

# The application is now the first argument.
app=$1

# Add the appropriate options for the application.
app_opts

/usr/bin/firejail --private $netopt $devopt $app $appopt "${@:2}"
