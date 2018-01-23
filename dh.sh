#!/bin/bash
# created by devhirano :)

# what is this
#  check exit status with kao-moji
#  check enabled/disabled proxy
#  git fetch automatically
#  cut hostname if too long it
#  simple mode, this is useful for copy/paste

# how to use
#  $ source dh.sh
#  restart terminal
#  done!

#   change mode
#    $ export __SIMPLE="true"
#
#      [devhirano@devhirano-HP~] ~ $ export __SIMPLE=true
#      ~ $
#
#    $ export __SIMPLE="false"
#      ~ $ export __SIMPLE=false
#      [devhirano@devhirano-HP~] ~ $

# many thanks
#  git-completion and git-prompt contributors

# strict
#  this can use for only bash

# configuration for dhprompt
__SHORTHOST="true"
__SHORTHOST_CHAR="8"
__SHORTUSER="true"
__SHORTUSER_CHAR="6"
__SIMPLE="false"
__FETCH_CHECK="true"
__FETCH_BRANCH="origin"
__GOOD_KAOMOJI_SHOW="false"
__GOOD_KAOMOJI=(":)")
__BAD_KAOMOJI_RANDOM="true"
__BAD_KAOMOJI=(":(" "(#\\\`_>´)" "(´-ω-\\\`)" "(;ω;)" "(ﾉД\\\`)" "┐(´д\\\`)┌")
__CHECK_NW="true"
__SHORTNW="true"
__SHORTNW_CHAR="4"
__DATE="true"
__DATE_FMT="%H:%M"
# __DATE_FMT="%H:%M:%S"
__SHOW_PROXY="true"
__INSTALLED_SCREEN=`which screen`
__SHOW_SCREEN_SESSIONS="true"
__SCREEN_SESSIONS_WC="0"

__CACHE_GITHOME="true"

# Directory color "BLUE/34" is hard to see so will be change it"
__LS_COLORS_DIR="1;33"

#-----------------------------------------------------------
# kaomoji
__ARRAY_SIZE=${#__BAD_KAOMOJI[*]}
__ARRAY_RAND=`expr $RANDOM % ${__ARRAY_SIZE}`


# dir
__SCRIPT_DIR="$HOME/.dhprompt"

[ -n $__LS_COLORS_DIR ] && export LS_COLORS="$LS_COLORS:di=$__LS_COLORS_DIR"

mkdir -p $__SCRIPT_DIR

which curl 1>&2 >/dev/null
if [ $? -ne 0 ];then
  sudo apt update && sudo apt install curl -y
fi

source $__SCRIPT_DIR/git-completion.bash
if [ $? -ne 0 ];then
  curl -o $__SCRIPT_DIR/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
  source $__SCRIPT_DIR/git-completion.bash
fi

source $__SCRIPT_DIR/git-prompt.sh
if [ $? -ne 0 ];then
  curl -o  $__SCRIPT_DIR/git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
  source $__SCRIPT_DIR/git-prompt.sh
fi

grep "dh.sh" $HOME/.bashrc > /dev/null
if [ $? -ne 0 ];then
  __FILEDIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
  __FILEPATH=`readlink -f "$__FILEDIR/dh.sh"`
  echo "source $__FILEPATH" >> $HOME/.bashrc
fi

INSERTED_LINE=$(grep -Ens '^source.*\/dh\.sh' $HOME/.bashrc | sed -e 's/:.*//g')
SHOULD_LINE=$(wc -l $HOME/.bashrc  |sed -e 's/ .*//g')
if [ "$INSERTED_LINE" != "$SHOULD_LINE" ]; then
  cp -fp ~/.bashrc ~/.bashrc.back
  __FILEPATH=$(grep -Ens '^source.*\/dh\.sh' $HOME/.bashrc |head -n 1| sed -e 's/.*://g')
  for i in $(echo ${INSERTED_LINE} | sed -e 's/ /\n/g' |tac)
  do
    sed -i "${i}d" $HOME/.bashrc
  done
  echo "$__FILEPATH" >> $HOME/.bashrc
fi

which bc 1>&2 >/dev/null
if [ $? -ne 0 ];then
  sudo apt update && sudo apt install bc -y
fi


######################################################
# you can write git-prompt and git-completion options

GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWUPSTREAM=AUTO
######################################################


__ISROOT="#"
id | grep 'uid=0(root)' 1>/dev/null 2>/dev/null
if [ "$?" != "0" ]
then
  __ISROOT="$"
fi

__SHORTHOSTNAME=`hostname`
if [ "$__SHORTHOST" == "true" ];then
  __HOSTLEN=`hostname | wc -c | xargs -I{} expr {} - 1`
  # __HOSTLEN=`hostname | wc -c`
  if [ $__HOSTLEN -gt ${__SHORTHOST_CHAR} ];then
    __SHORTHOSTNAME=`hostname | cut -b -${__SHORTHOST_CHAR}`~
  fi
fi

__SHORTUSERNAME=`whoami`
if [ "$__SHORTUSER" == "true" ];then
  __USERLEN=`whoami | wc -c | xargs -I{} expr {} - 1`
  # __USERLEN=`whoami | wc -c`
  if [ $__USERLEN -gt ${__SHORTUSER_CHAR} ];then
    __SHORTUSERNAME=`whoami | cut -b -${__SHORTUSER_CHAR}`~
  fi
fi

RANDCOLOR=$(( $RANDOM * 6 / 32767 + 1 ))
RANDCOLOR="\[\e[3${RANDCOLOR}m\]"

__IS_PYENV=`which pyenv 2>/dev/null`
__PYENV_MESSAGE=""


# Prepare Logging
__AUTO_LOGGING="true"
LOGGING_ONESHOT=""
CURRENT_LOGGING=""
__SCRIPT_PID="INCORRECTPID"
__LOG_DIR="$HOME/.dhprompt/log"
__LOG_FILE_DATE_FORMAT_PREFIX="%Y%m%d"
__LOG_FILE_DATE_FORMAT_SUFFIX="%H%M%S"
__LOG_NAME_PREFIX="$(date +${__LOG_FILE_DATE_FORMAT_PREFIX})"
__LOG_NAME_SUFFIX="$(date +${__LOG_FILE_DATE_FORMAT_SUFFIX})"
__LOG_FILE_COMMAND="${__LOG_DIR}/${__LOG_NAME_PREFIX}-${__LOG_NAME_SUFFIX}-$$-command.log"
__LOG_FILE_STD="${__LOG_DIR}/${__LOG_NAME_PREFIX}-${__LOG_NAME_SUFFIX}-$$-std.log"
[ -d "${__LOG_DIR}" ] || mkdir -p ${__LOG_DIR}

# Output out
__OUTPUT_TARGET="/dev/null"


CURRENT_XTRACE=""

stash_xtrace () {
    {
    if [ -z "$CURRENT_XTRACE" -o "$CURRENT_XTRACE" != "$-" ]; then
        CURRENT_XTRACE=$- &> /dev/null
    fi
    } > ${__OUTPUT_TARGET} 2>&1
}

dhprompt () {
    {
    EXITSTATUS="$?" >/dev/null 2>&1

    stash_xtrace
    set +x

    if [ "$__DATE" == "true" ];then
        __NOW=`date +"${__DATE_FMT}"`" "
    else
        __NOW=""
    fi

    if [ "${previous_command}" = "dhprompt" ]; then
        PS1="${__NOW}${YELLOW}\W${OFF} ${__ISROOT} "
        case "${CURRENT_XTRACE}" in
            *x* )
                set -x
                ;;
            *)
                ;;
        esac
        CURRENT_XTRACE=""
        return 0
    fi

    # Logging Command
    if [ -n "${__AUTO_LOGGING}" ];then
      echo ${previous_command} >> ${__LOG_FILE_COMMAND}
    fi

    if [ "$__SIMPLE" == "true" ];then
      PS1="\W ${__ISROOT} "
      PS2="${BOLD}>${OFF} "
      return
    fi

    BOLD="\[\033[1m\]"
    RED="\[\033[1;31m\]"
    GREEN="\[\e[32;1m\]"
    BLUE="\[\e[34;1m\]"
    YELLOW="\[\e[33;1m\]"
    CYAN="\[\e[36;1m\]"
    VIOLET="\[\e[35;1m\]"
    OFF="\[\033[m\]"

    if [ "$__CACHE_GITHOME" == "true" ];then
      ls .git 1>/dev/null 2>/dev/null
      if [ $? == 0 ];then
        __CACHE_GITHOME_PATH=`pwd`
        export RR=$__CACHE_GITHOME_PATH
      fi
    fi

    if [ "${__IS_PYENV}" != "" ];then
      __PYENV_VERSION=`pyenv version 2>/dev/null |awk '{print $1}'` |sed -e 's/\\n//'
      if [ $? == 0 -a "${__PYENV_VERSION}" != "" ];then
          __PYENV_MESSAGE=" (${__PYENV_VERSION})"
      else
          __PYENV_MESSAGE=""
      fi
    fi


    __SHORTNWNAME=`ip route get 8.8.8.8 2>/dev/null | head -n 1 | sed -e "s/.*dev //" | sed -e "s/ *src .*//" `
    if [ "$__SHORTNW" == "true" ];then
      __NWLEN=`echo ${__SHORTNWNAME} | wc -c | xargs -I{} expr {} - 1`
      if [ $__NWLEN -gt ${__SHORTNW_CHAR} ];then
        __SHORTNWNAME=`echo ${__SHORTNWNAME} | cut -b -${__SHORTNW_CHAR}`~
      fi
    fi
    # CHECKPUBLICROUTE_DEV=`ip route get 8.8.8.8 2>/dev/null | head -n 1 | sed -e "s/.*dev //" | sed -e "s/ *src .*//"`
    PROMPT="[${RANDCOLOR}${__SHORTUSERNAME}${OFF}@${RANDCOLOR}${__SHORTHOSTNAME}${OFF}(${__SHORTNWNAME})] ${YELLOW}\W${OFF}"

    __GIT_REMOTE_AMOUNT=`git remote -v 2>/dev/null |wc -l`
    if [ -a "./.git" -a "$__FETCH_CHECK" == "true" -a $__GIT_REMOTE_AMOUNT -ge 1 -a -e ".git/HEAD" ];then
        # this is what I need:
        last_fetch_date=`stat .git/FETCH_HEAD 2>/dev/null |grep Modify | awk '{print $2" "$3}' 2>/dev/null`

        # do the math to see how long ago
        timestamp=`date -d "$last_fetch_date" +%s 2>/dev/null`
        now=`date +%s`
        diff=`echo $now - $timestamp | bc -l 2>/dev/null`

        # one hour
        if [ `echo $diff' >= 60*60' | bc -l` == "1" ]; then
            git remote |grep ${__FETCH_BRANCH} 1>/dev/null 2>/dev/null
            if [ $? == 0 ];then
              echo "!dhprompt: git fetched date is too long, force fetch remote"
              git fetch --tags 2>/dev/null
              if [ $? == 0 ];then
                echo "!dhprompt: git diff ${__FETCH_BRANCH}/master --stat"
                git diff ${__FETCH_BRANCH}/master --stat
              else
                echo "!dhprompt: doesn't have ${__FETCH_BRANCH} branch"
              fi
            fi
        fi
    fi

    PROXYVAR=""
    if [ "$__SHOW_PROXY" == "true" ];then
      if [ -n "$HTTP_PROXY" -o -n "$HTTPS_PROXY" -o -n "$http_proxy" -o -n "$https_proxy" ]; then
        PROXYVAR=" [P";
      fi
    fi
    if [ "${__SHOW_SCREEN_SESSIONS}" == "true" -a "${__INSTALLED_SCREEN}" != "" ];then
      __SCREEN_SESSIONS_WC=`expr $(screen -ls | wc -l) - 2`
      if [ "$PROXYVAR" == "" ];then
        PROXYVAR=" [s${__SCREEN_SESSIONS_WC}]"
      else
        PROXYVAR="${PROXYVAR}s${__SCREEN_SESSIONS_WC}]"
      fi
    else
      if [ "$PROXYVAR" != "" ];then
        PROXYVAR="${PROXYVAR}]"
      fi
    fi

    if [ "${EXITSTATUS}" -eq 0 ]
    then
      # PS1="${PROMPT} ${BOLD}${GREEN}:)${OFF}$(__git_ps1)]\$ "

      if [ "$__GOOD_KAOMOJI_SHOW" == "true" ];then
        # PS1="${__NOW}${PROMPT}${PROXYVAR}${__PYENV_MESSAGE} ${BOLD}${GREEN}${__GOOD_KAOMOJI[0]}${OFF}$(__git_ps1) ${__ISROOT} "
        PS1="${__NOW}${PROMPT}${PROXYVAR}${__PYENV_MESSAGE} ${BOLD}${GREEN}${__GOOD_KAOMOJI[0]}${OFF}$(__git_ps1) ${__ISROOT} \n${__NOW}${YELLOW}\W${OFF} ${__ISROOT} "
      else
        # PS1="${__NOW}${PROMPT}${PROXYVAR}${__PYENV_MESSAGE}${OFF}$(__git_ps1) ${__ISROOT} "
        PS1="${__NOW}${PROMPT}${PROXYVAR}${__PYENV_MESSAGE}${OFF}$(__git_ps1) ${__ISROOT} \n${__NOW}${YELLOW}\W${OFF} ${__ISROOT} "
      fi
    else
      if [ "$__BAD_KAOMOJI_RANDOM" == "true" ];then
        # __ARRAY_RAND=`expr $RANDOM % ${__ARRAY_SIZE}`
        __BAD_KAOMOJI_SHOW=${__BAD_KAOMOJI[${__ARRAY_RAND}]}
      else
        __BAD_KAOMOJI_SHOW=${__BAD_KAOMOJI[0]}
      fi

      # PS1="${PROMPT}${PROXYVAR}${BOLD}${RED}:(${OFF}$(__git_ps1) ${__ISROOT} "
      PS1="${__NOW}${PROMPT}${PROXYVAR}${__PYENV_MESSAGE}${BOLD}${RED} ${__BAD_KAOMOJI_SHOW}${OFF}$(__git_ps1) ${__ISROOT} \n${__NOW}${YELLOW}\W${OFF} ${__ISROOT} "
    fi

	# WORKING_DIRECTORY='\[\e[$[COLUMNS-$(echo -n " (\w)" | wc -c)]C\e[1;35m(\w)\e[0m\e[$[COLUMNS]D\]'
	# PS1=${WORKING_DIRECTORY}${PS1}

    PS2="${BOLD}>${OFF} "
    if [ "${previous_command}" != "dhprompt" ]; then
        echo
        echo "(command: ${previous_command})"
    else
        PS1="${__NOW}${YELLOW}\W${OFF} ${__ISROOT} "
    fi
    # PS1="${__NOW}${YELLOW}\W${OFF} ${__ISROOT} "


    case "${CURRENT_XTRACE}" in
        *x* )
            set -x
            ;;
        *)
            ;;
    esac
    CURRENT_XTRACE=""

    } > ${__OUTPUT_TARGET} 2>&1
}

# ppid が script なら起動済み
if [ -n "${__AUTO_LOGGING}" -o -n "${LOGGING_ONESHOT}" ];then
  CURRENT_LOGGING=$(ps -o pid,args -e |grep "$(ps -p $(echo $$) -o ppid)" | grep -v grep | grep [s]cript)
  if [ -z "$CURRENT_LOGGING" ];then
    script -a ${__LOG_FILE_STD}
    echo "*** auto logging is using "script" command, so terminal is wrapped in it ***"
    echo "*** first "exit" is for script command, then you should exit twice when exit terminal ***"
  fi
fi

enable_terminal_logging () {
    LOGGING_ONESHOT="true"
}

PROMPT_COMMAND=dhprompt
trap '{ stash_xtrace; previous_command=$this_command; this_command=$BASH_COMMAND; } > ${__OUTPUT_TARGET} 2>&1' DEBUG > /dev/null 2>&1

