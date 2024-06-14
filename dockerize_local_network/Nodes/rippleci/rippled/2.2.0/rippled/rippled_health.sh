#!/usr/bin/env bash

server_state=$(rippled --silent server_state)
state_regex='"server_state" : "(\w+)"'
complete_ledgers_regex='"complete_ledgers" : "([[:digit:]]+-[[:digit:]]+)"' # BUG: will break on gaps

if [[ $server_state =~ $state_regex ]]; then
    state="${BASH_REMATCH[1]}"
fi

if [[ $server_state =~ $complete_ledgers_regex ]]; then
    complete_ledgers="not_empty"
    # echo ${BASH_REMATCH[1]}
fi

if [[ $state = "full"  &&  $complete_ledgers = "not_empty" ]]; then
    exit 0
fi

exit 1
