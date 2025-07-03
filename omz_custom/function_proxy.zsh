# 开启系统代理
function proxy_on() {
    local PROXY_IP=${PROXY_IP:-"127.0.0.1"}
    export https_proxy=http://$PROXY_IP:7890
    export http_proxy=http://$PROXY_IP:7890
    export all_proxy=socks5://$PROXY_IP:7890
	export no_proxy=127.0.0.1,localhost
	echo -e "\033[32m[√] 已开启代理:$PROXY_IP\033[0m"
}

function proxy_on2() {
    local PROXY_IP=${PROXY_IP:-"127.0.0.1"}
    export https_proxy=http://$PROXY_IP:8890
    export http_proxy=http://$PROXY_IP:8890
    export all_proxy=socks5://$PROXY_IP:8890
	export no_proxy=127.0.0.1,localhost
	echo -e "\033[32m[√] 已开启代理:$PROXY_IP\033[0m"
}

function pon(){
  proxy_on
}

function pon2(){
  proxy_on2
}

# 关闭系统代理
function proxy_off(){
	unset http_proxy
	unset https_proxy
	unset all_proxy
	unset no_proxy
	echo -e "\033[31m[×] 已关闭代理\033[0m"
}

function poff(){
  proxy_off
}

