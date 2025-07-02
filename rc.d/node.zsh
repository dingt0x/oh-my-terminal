# NVM
# install from souce code

export NVM_DIR="$HOME/.nvm"

cat << 'EOF' > /dev/null
export LDFLAGS="-L/usr/local/opt/node@22/lib"
export CPPFLAGS="-I/usr/local/opt/node@22/include"
EOF

#_remove_from_path() {
#    local path_to_remove="${1:-""}"
#    if [ -z "$path_to_remove" ]; then
#        return
#    fi
#    local path=":$PATH:"
#    path=${path//":$path_to_remove:"/":"}
#    path=${path#:}
#    path=${path%:}
#    export PATH="$path"
#}

_remove_from_path(){
    local path_to_remove="${1:-""}"
    if [ -z "$path_to_remove" ]; then
        return
    fi
    PATH=$(echo "$PATH"|/usr/bin/sed -E -e "s#(^|:)${path_to_remove}(:|$)#\1\2#g" -e 's/::/:/g' -e 's/^://' -e 's/:$//')
}
# TODO LAZY LOAD
function enable-nvm(){
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"  || echo "$NVM_DIR/nvm.sh does not exist" # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" || echo "$NVM_DIR/bash_completion does not exist" # This loads nvm bash_completion
    # export NVM_NODEJS_ORG_MIRROR=http://npm.taobao.org/mirrors/node
}

if [ "$ENABLE_NVM" = "true" ]; then
    enable-nvm
fi


# tj/n
export N_PREFIX="${HOME}/.n"

if [ ! -d "${N_PREFIX}" ]; then
    mkdir "${N_PREFIX}"
fi



n.env(){
    if [ "${#}" -eq "0" ]; then
        echo "Usage: n.env [version]"
        return
    fi

    local node_version_dir
    local set_node_version
    local set_node_path

    node_version_dir="${N_PREFIX}/n/versions/node"
    set_node_version=${1}

    set_node_path="${node_version_dir}/${set_node_version}/bin"

     if ! echo "$set_node_version" |grep -qE '^[0-9]{1,2}\.[0-9]{1,2}'; then
         _n_cmd "$@"
         return
     fi

    if ! [ -d "${set_node_path}" ]; then
        echo "NODE Version ${set_node_version} not found in ${node_version_dir}."
        return 1
    fi

    if [ -n "$NODE_PATH" ]; then
        echo "$NODE_PATH"
        _remove_from_path "$NODE_PATH"
    fi

    export PATH="${set_node_path}:${PATH}"
    export NODE_PATH="${set_node_path}"
    export NODE_VERSION="${set_node_version}"
}

_n_cmd(){
    local set_node_version; set_node_version=$1
    case "$set_node_version" in
        "ls"|"lsr")
            n "$set_node_version"
            return
            ;;
        "--help"|"-h"|"--version"|"-v")
            return
            ;;
    esac

}

if [ -n "$NODE_VERSION" ]; then
    n.env "$NODE_VERSION" > /dev/null 2>&1
fi