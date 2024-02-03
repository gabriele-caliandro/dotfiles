SSH_ENV="$HOME/.ssh/agent-environment"

function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    # Attempt to add every file in ~/.ssh as a private key, with basic filtering
    for key in $HOME/.ssh/*; do
        # Exclude directories and known non-private key files
        if [[ -f "$key" && ! "$key" == *.pub && ! "$key" =~ \.conf$ && ! "$key" == *authorized_keys && ! "$key" == *known_hosts ]]; then
            echo "Attempting to add $key to the SSH agent"
            /usr/bin/ssh-add "$key" >/dev/null 2>&1
        fi
    done
}


# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

