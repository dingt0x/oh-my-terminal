# GO
# export GO111MODULE=auto
# export GOROOT="${HOME}/Miduo/go1.19.12"
# export GOPATH="${HOME}/go"
# 
# export PATH="${PATH}:${GOROOT}/bin:${GOPATH}/bin"
# refer github page to install voidint/g
# https://github.com/voidint/g

# TODO 解耦PATH
_go_remove_from_path(){
    local path_to_remove="${1:-""}"
    if [ -z "$path_to_remove" ]; then
        return
    fi
    PATH=$(echo "$PATH"|/usr/bin/sed -E -e "s#(^|:)${path_to_remove}(:|$)#\1\2#g" -e 's/::/:/g' -e 's/^://' -e 's/:$//')
}

if [[ -n $(alias g 2>/dev/null) ]]; then
unalias g
fi

export G_PREFIX="${HOME}/.g"
export G_MIRROR=https://mirrors.aliyun.com/golang/
export PATH="${G_PREFIX}/bin:$PATH"

export GOPROXY="https://goproxy.cn,direct"
export GO_HOME="${HOME}/.g/versions"
export GO_ENVS="${HOME}/goenvs"
if [ ! -d "$GO_ENVS" ]; then
    mkdir "$GO_ENVS"
fi
g.env(){
    local set_go_version; set_go_version=${1:-""}
     if ! echo "$set_go_version" |grep -qE '^[0-9]{1,2}\.[0-9]{1,2}'; then
         _g_cmd "$@"
         return
     fi
    local SET_GOROOT="${GO_HOME}/$set_go_version"
    local SET_GOPATH="${GO_ENVS}/${set_go_version}:${HOME}/go"

    if [ ! -d "$SET_GOROOT" ]; then
        echo "${SET_GOROOT} not found"
        return
    fi


    if [ -n "${GOROOT}" ]; then
        local go_root_path="${GOROOT}/bin"
        _go_remove_from_path "$go_root_path"

    fi


    if [ -n "${GOPATH}" ]; then
        local go_path_path="${GOPATH%%:*}/bin"
        _go_remove_from_path "${go_path_path}"
        _go_remove_from_path "${HOME}/go/bin"
    fi

    PATH="${SET_GOPATH%%:*}/bin:${HOME}/go/bin:$PATH"
    set_go_root_path="${SET_GOROOT}/bin"
    set_go_path_path="${SET_GOPATH%%:*}/bin:${HOME}/go/bin"

    if [ ! -d "${SET_GOPATH%%:*}" ]; then
        mkdir -p  "${SET_GOPATH%%:*}"
    fi

    export PATH="$set_go_path_path:$set_go_root_path:$PATH"
    export GOROOT="$SET_GOROOT"
    export GOPATH="$SET_GOPATH"
    export GO_VERSION="${set_go_version}"

    g use "$set_go_version"
}


_create_go_version_file(){
    local go_version
    go_version="${1:-""}"
    if [ -z "$go_version" ]; then
        echo "No Go version is provided."
        return 1
    fi
    local GO_VERSION_PATH="$HOME/.g/versions"
    local GO_VERSION_BIN_FILE="${GO_VERSION_PATH}/${go_version}/bin/go"
    local GO_BIN_FILE="$HOME/.g/bin/go${go_version}"

    if [ ! -f "${GO_VERSION_BIN_FILE}" ]; then
        echo "Go version NOT FOUND in ${GO_VERSION_PATH}."
        return 1
    fi

    if [ ! -d "$HOME/goenvs/$go_version" ]; then
        mkdir -p "$HOME/goenvs/$go_version"
    fi

    (
    echo '#/bin/bash'
    echo "go_version=$go_version"
    echo "go_version_path=$GO_VERSION_PATH"
    echo 'export GOROOT="${go_version_path}/${go_version}"'
    echo 'export GOPATH="${HOME}/goenvs/${go_version}:${HOME}/go"'
    echo ''
    echo 'exec "${go_version_path}/${go_version}/bin/go" "$@"'
    ) > "$GO_BIN_FILE"

    chmod +x "$GO_BIN_FILE"
}
_g_cmd(){
    local set_go_version; set_go_version=$1
    case "$set_go_version" in
        "i"|"install")
            shift
            for arg in "$@"; do
                if ! echo "$arg" |grep -qE '^[0-9]{1,2}\.[0-9]{1,2}'; then
                    continue
                fi
                if ! "${HOME}/.g/bin/g" install -n "$arg"; then
                    return 1
                fi
                _create_go_version_file "$arg"
                break
            done
            return
            ;;
        "ls"|"l"|"ls-remote"|"lr"|"lsr"|"uninstall"|"clean"|"env"|"self"|"help"|"h")
            "${HOME}/.g/bin/g" "$@"
            return
            ;;
        "use"):
            echo "Do nothing"
            return
            ;;
        "--help"|"-h"|"--version"|"-v")
            "${HOME}/.g/bin/g" "$@"
            return
            ;;
        "--update")
            _update_go
            return
            ;;
    esac

}
_update_go() {
    local GO_VERSION_PATH="$HOME/.g/versions"
    local go_version

    for i in "$GO_VERSION_PATH"/*; do
        if [ ! -d "$i" ]; then
            continue
        fi
        go_version=$(basename "$i")
        _create_go_version_file "${go_version}"
    done
}



go_mod_versions() {
	# Example Command:
	# go list -m -versions gorm.io/driver/sqlite
	# go list -m -versions gorm.io/driver/mysql
	# go mod download -json gorm.io/driver/mysql@v0.1.0
	#
	local GO111MODULE="on"
	local module
	module="$1"
	if [ -z "$module" ] || [ "${module:0:1}" = "-" ]; then
		echo "Usage: $0 <module>"
        echo "Example: $0 gorm.io/driver/mysql"
		return 1
	fi

	echo "$module"
	for version in $(go list -m -versions "$module" | cut -d' ' -f2-); do
		echo -n "$version: "
		go mod download -json "$module@$version" |
			jq -r '.GoMod' |
			xargs cat |
			grep --color=never '^go ' ||
			echo "None"
	done
}


if [ -n "$GO_VERSION" ]; then
    g.env "$GO_VERSION" > /dev/null
fi
