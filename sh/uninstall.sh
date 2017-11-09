#!/bin/bash

PROXY_CONF_DIR=/usr/local/etc/wavefront
LOG_DIR=/usr/local/var/log
PROXY_LOG_DIR=${LOG_DIR}/wavefront
ETC_DIR=/usr/local/etc
PROXY_SPOOL_DIR=/usr/local/var/spool/wavefront-proxy

function list_removal() {
    echo "This will uninstall the following:"
    echo -e "\t Wavefront proxy"
    echo -e "\t Wavefront telegraf agent"
    echo -e "\t Homebrew Wavefront tap"
    echo -e "\t Homebrew Java installation (optional)"
    echo -e "\t Homebrew (optional)"
}

function uninstall_cmd() {
    CMD=$1
    CMD_PATH=$(brew list $CMD)
    if [ $? -eq 0 ]; then
        brew services stop $CMD
        brew uninstall $CMD
    fi
}

function delete_proxy_files() {
    rm -rf ${PROXY_CONF_DIR}
    rm -rf ${PROXY_LOG_DIR}
    rm -rf ${PROXY_SPOOL_DIR}
}

function delete_telegraf_files() {
    rm -f ${ETC_DIR}/telegraf.conf
    rm -f ${ETC_DIR}/telegraf.conf.default
    rm -f ${ETC_DIR}/telegraf.conf.old
    rm -rf ${ETC_DIR}/telegraf.d
    rm -f ${LOG_DIR}/telegraf.log
}

function prompt_user() {
    MSG=$1
    read -p "$1 (y/N)? " answer
    case ${answer:0:1} in
        y|Y )
            return 0
        ;;
        * )
            return 1
        ;;
    esac
}

function uninstall_cask_java() {
    if [ -d /usr/local/Caskroom/java ]; then
        prompt_user "Uninstall Homebrew Java installation"
        if [ $? -eq 0 ]; then
            brew cask uninstall java
        else
            echo "Java will not be uninstalled"
        fi
    fi
}

function uninstall_homebrew() {
    BREW_PATH=$(which brew) 
    if [ $? -eq 0 ]; then
        prompt_user "Uninstall Homebrew installation"
        if [ $? -eq 0 ]; then
            ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
        fi
    fi
}

list_removal

prompt_user "Do you wish to continue"
if [ $? -ne 0 ]; then
    exit 0
fi

uninstall_cmd wfproxy
delete_proxy_files
uninstall_cmd wftelegraf
delete_telegraf_files
brew untap wavefronthq/wavefront

uninstall_cask_java
uninstall_homebrew
