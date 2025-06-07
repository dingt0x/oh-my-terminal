# shellcheck disable=SC1078
# shellcheck disable=SC2045
# shellcheck disable=SC2046
# shellcheck disable=SC2012
function load_ssh_agent(){
    if [ -S "$SSH_AUTH_SOCK" ]; then
        return
    fi

    if [ "$(uname)" = "Darwin" ]; then
        load_ssh_agent_macos
    else
        load_ssh_agent_linux
    fi
}

function load_ssh_agent_macos(){
    for dir in $(ls -dt /tmp/com.apple.launchd.*); do
        if [ -S "$dir/Listeners" ]; then
            SSH_AUTH_SOCK="$dir/Listeners"
            export SSH_AUTH_SOCK
            # echo "SSH_AUTH_SOCK $SSH_AUTH_SOCK"
            return
        fi
    done
}

function load_ssh_agent_linux(){
    SSH_AGENT_PID=$(pgrep "^ssh-agent$"|tail -1)
    if [ -z "$SSH_AGENT_PID" ] ; then

        eval $(ssh-agent -s)
    else
        count=0
        for dir in $(ls -dt /tmp/ssh-*); do
            count=$((count + 1))

            if [ "$count" -eq "1" ]; then
                FIRST_FILE=$(ls -1 "$dir" | head -n 1)
                if [ -S "$dir/$FIRST_FILE" ]; then
                    SSH_AUTH_SOCK="$dir/$FIRST_FILE"
                fi
            fi

            if [ "$count" -gt "3" ]; then
                rm -rf "$dir"
            fi
        done
        unset FIRST_FILE
        unset count
        export SSH_AUTH_SOCK
        export SSH_AGENT_PID
    fi
}

load_ssh_agent
unset -f load_ssh_agent
unset -f load_ssh_agent_linux
unset -f load_ssh_agent_macos

