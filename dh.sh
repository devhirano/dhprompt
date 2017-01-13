#!/bin/bash

#SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
SCRIPT_DIR="$HOME/.dhprompt"

mkdir -p $SCRIPT_DIR

source $SCRIPT_DIR/git-completion.bash
if [ $? -ne 0 ];then
  curl -o $SCRIPT_DIR/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
  source $SCRIPT_DIR/git-completion.bash
fi

source $SCRIPT_DIR/git-prompt.sh
if [ $? -ne 0 ];then
  curl -o  $SCRIPT_DIR/git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
  source $SCRIPT_DIR/git-prompt.sh
fi

grep "dh.sh" $HOME/.bashrc > /dev/null
if [ $? -ne 0 ];then
  FILEPATH=`readlink -f dh.sh`
  echo "source $FILEPATH " >> $HOME/.bashrc
fi

######################################################
# you can write git-prompt and git-completion options

GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWUPSTREAM=AUTO
######################################################


ISROOT="#"
id | grep 'uid=0(root)' 1>/dev/null 2>/dev/null
if [ "$?" != "0" ]
then
  ISROOT="$"
fi

__FULLHOST="no"
__SHORTHOSTNAME=`hostname`
if [ "$__FULLHOST" == "no" ];then
  __HOSTLEN=`hostname | wc -c`
  if [ $__HOSTLEN -ge 12 ];then
    __SHORTHOSTNAME=`hostname | cut -c -12`..
  fi
fi

function exitstatus {
    EXITSTATUS="$?"
    BOLD="\[\033[1m\]"
    RED="\[\033[1;31m\]"
    GREEN="\[\e[32;1m\]"
    BLUE="\[\e[34;1m\]"
    YELLOW="\[\e[33;1m\]"
    CYAN="\[\e[36;1m\]"
    VIOLET="\[\e[35;1m\]"
    OFF="\[\033[m\]"

    # PROMPT="[\u@\h ${BLUE}\W${OFF}"
    PROMPT="[\u@${__SHORTHOSTNAME}] ${YELLOW}\W${OFF}"

    __FETCH_CHECK="true"
    __GIT_REMOTE_AMOUNT=`git remote -v 2>/dev/null |wc -l`
    ls .git 1>/dev/null 2>/dev/null
    if [ $? == 0 -a "$__FETCH_CHECK" == "true" -a $__GIT_REMOTE_AMOUNT -ge 1 ];then
        # this is what I need:
        last_fetch_date=`stat .git/FETCH_HEAD 2>/dev/null |grep Modify | awk '{print $2" "$3}' 2>/dev/null`
        
        # do the math to see how long ago
        timestamp=`date -d "$last_fetch_date" +%s 2>/dev/null`
        now=`date +%s`
        diff=`echo $now - $timestamp | bc -l 2>/dev/null`
        
        # two days
        if [ `echo $diff' >= 2*24*60' | bc -l` == "1" ]; then
            echo "!dhprompt: git fetched date is too long, force fetch remote"
            git fetch --tags
            echo "!dhprompt: done"
        fi
    fi

    PROXYVAR=" "
    if [ -n "$HTTP_PROXY" -o -n "$HTTPS_PROXY" -o -n "$http_proxy" -o -n "$https_proxy" ]; then
      PROXYVAR=" (P) ";
    fi

    if [ "${EXITSTATUS}" -eq 0 ]
    then
       # PS1="${PROMPT} ${BOLD}${GREEN}:)${OFF}$(__git_ps1)]\$ "
       PS1="${PROMPT}${PROXYVAR}${BOLD}${GREEN}:)${OFF}$(__git_ps1) ${ISROOT} "
    else
       # PS1="${PROMPT} ${BOLD}${RED}:(${OFF}$(__git_ps1)]\$ "
       # PS1="${PROMPT}${PROXYVAR}${BOLD}${RED}(#\\\`_>´) <($?) ${OFF}$(__git_ps1) ${ISROOT} "
       PS1="${PROMPT}${PROXYVAR}${BOLD}${RED}:(${OFF}$(__git_ps1) ${ISROOT} "
    fi

    PS2="${BOLD}>${OFF} "
}

PROMPT_COMMAND=exitstatus

