#!/bin/bash
# created by devhirano
# https://github.com/devhirano/dhprompt

__AUTO_SCREEN=1

# enter screen first
function recursive_ppid {
  pid=${1:-$$}
  stat=($(</proc/${pid}/stat))
  ppid=${stat[3]}

  if [[ $(cat /proc/${ppid}/comm 2>/dev/null) == "screen" ]]; then
      :
  elif [[ $(ps auxww |grep gnome-session-binar[y] |wc -l) -le 0 ]]; then
      # this is used for fedora x-window startup problem
      :
  elif [ -z ${DISPLAY} ]; then
      :
  elif [[ ${ppid} -eq 0 ]]; then
      mkdir -p "$HOME/.screen"
      chmod 700 $HOME/.screen
      export SCREENDIR="$HOME/.screen"
      screen
  else
      recursive_ppid ${ppid}
  fi
}

[ -n "$__AUTO_SCREEN" ] && recursive_ppid $$

function recursive_script {
  pid=${1:-$$}
  stat=($(</proc/${pid}/stat))
  ppid=${stat[3]}

  if [[ $(cat /proc/${ppid}/comm 2>/dev/null) == "script" ]]; then
      echo 0
  elif [[ ${ppid} -eq 0 ]]; then
      echo 1
  else
      recursive_script ${ppid}
  fi
}

__DHPROMPT_BANNER="true"
__AUTO_SIZING="true"
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
__SHOW_PROXY="true"
__INSTALLED_SCREEN=`which screen`
__SHOW_SCREEN_SESSIONS="true"
__SCREEN_SESSIONS_WC="0"
__CACHE_GITHOME="true"

# format
DIRPATH="\w"
__DATE_FMT="%H:%M"


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

# need pkg installing
__missing_pkgs_repos=()
__check_need_programs () {
  for i in 'bc' 'curl' 'git'
  do
  which $i >/dev/null 2>&1
  if [ $? -ne 0 ];then
    __missing_pkgs_repos=("${__missing_pkgs_repos[@]}" $i)
  fi
  done
  if [ -n "${__missing_pkgs_repos}" ];then
    while :
    do
    echo " *** dhprompt notice *** "
    echo -n " missing some packages for using dhprompt: "
    echo "${__missing_pkgs_repos[@]}"
    echo -n " do you install it from repositroy? [Y/n]: "
    read __answer
    case $__answer in
      '' | [Yy]* )
        sudo apt update && sudo apt -y install "${__missing_pkgs_repos[@]}"
        break;
        ;;
      [Nn]* )
        echo " maybe some function doesn't run correctly."
        break;
        ;;
      * )
        ;;
    esac
    done
  fi
}

__check_need_programs

source $__SCRIPT_DIR/git-completion.bash >/dev/null 2>&1
if [ $? -ne 0 ];then
    if [ $(which curl) ];then
  echo -n "installing git-completion..."
  curl -s -o $__SCRIPT_DIR/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
  source $__SCRIPT_DIR/git-completion.bash
  echo "done"
  fi
fi

source $__SCRIPT_DIR/git-prompt.sh >/dev/null 2>&1
if [ $? -ne 0 ];then
    if [ $(which curl) ];then
  echo -n "installing git-prompt..."
  curl -s -o  $__SCRIPT_DIR/git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
  source $__SCRIPT_DIR/git-prompt.sh
  echo "done"
  fi
fi

grep "dh.sh" $HOME/.bashrc > /dev/null
if [ $? -ne 0 ];then
  __FILEDIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
  __FILEPATH=`readlink -f "$__FILEDIR/dh.sh"`
  echo "[ -n \"$DISPLAY\" ] && pgrep gnome-terminal >/dev/null 2>&1 && source $__FILEPATH" >> $HOME/.bashrc
fi

INSERTED_LINE=$(grep -Ens 'source.*\/dh\.sh' $HOME/.bashrc | sed -e 's/:.*//g')
SHOULD_LINE=$(wc -l $HOME/.bashrc  |sed -e 's/ .*//g')
if [ "$INSERTED_LINE" != "$SHOULD_LINE" ]; then
  cp -fp ~/.bashrc ~/.bashrc.back
  __FILEPATH=$(grep -Ens 'source.*\/dh\.sh' $HOME/.bashrc |head -n 1| sed -e 's/.*://g')
  for i in $(echo ${INSERTED_LINE} | sed -e 's/ /\n/g' |tac)
  do
    sed -i "${i}d" $HOME/.bashrc
  done
  echo "$__FILEPATH" >> $HOME/.bashrc
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
__TERM_I=1
__AUTO_LOGGING="true"
LOGGING_ONESHOT=""
CURRENT_LOGGING=""
__SCRIPT_PID="INCORRECTPID"
__LOG_DIR="$HOME/.dhprompt/log"
__LOG_FILE_DATE_FORMAT_PREFIX="%Y%m%d"
__LOG_FILE_DATE_FORMAT_SUFFIX="%H%M%S"
__LOG_NAME_PREFIX="$(date +${__LOG_FILE_DATE_FORMAT_PREFIX})"
__LOG_NAME_SUFFIX="$(date +${__LOG_FILE_DATE_FORMAT_SUFFIX})"

until [ ! -f "${__LOG_DIR}/${__LOG_NAME_PREFIX}/${__TERM_I}-command.log" ]
do
  __TERM_I=$(( $__TERM_I + 1 ))
done
__LOG_FILE_COMMAND="${__LOG_DIR}/${__LOG_NAME_PREFIX}/${__TERM_I}-command.log"
__LOG_FILE_STD="${__LOG_DIR}/${__LOG_NAME_PREFIX}/${__TERM_I}-std.log"
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

auto_resize () {
  set -x
  __RESERVE_CHAR=20
  __CURRENT_DIR_SIZE=$(basename $(pwd) | wc -m)
  __HOSTNAME_SIZE=$(hostname | wc -m)
  __USERNAME_SIZE=$(whoami | wc -m)
  __NWNAME_SIZE=`ip route get 8.8.8.8 2>/dev/null | head -n 1 | sed -e "s/.*dev //" | sed -e "s/ *src .*//" | wc -m`
  if [ $(($COLUMNS - $__RESERVE_CHAR - $__CURRENT_DIR_SIZE - $__HOSTNAME_SIZE - $__USERNAME_SIZE - $__NWNAME_SIZE)) -le 0 ];then
      __SHORTUSER="true"
      __SHORTHOST="true"
      __SHOTNW="true"
  else
      __SHORTUSER="false"
      __SHORTHOST="false"
      __SHOTNW="false"
  fi
  set +x
}

set_hostname () {
__SHORTHOSTNAME=`hostname`
if [ "$__SHORTHOST" == "true" ];then
  __HOSTLEN=`hostname | wc -c | xargs -I{} expr {} - 1`
  # __HOSTLEN=`hostname | wc -c`
  if [ $__HOSTLEN -gt ${__SHORTHOST_CHAR} ];then
    __SHORTHOSTNAME=`hostname | cut -b -${__SHORTHOST_CHAR}`~
  fi
fi
}

set_username () {
__SHORTUSERNAME=`whoami`
if [ "$__SHORTUSER" == "true" ];then
  __USERLEN=`whoami | wc -c | xargs -I{} expr {} - 1`
  # __USERLEN=`whoami | wc -c`
  if [ $__USERLEN -gt ${__SHORTUSER_CHAR} ];then
    __SHORTUSERNAME=`whoami | cut -b -${__SHORTUSER_CHAR}`~
  fi
fi
}

timer_start () {
  timer=${timer:-$SECONDS}
}

timer_stop () {
  timer_show=$(($SECONDS - $timer))
  unset timer
}

dhprompt () {
  OPTIND=1
  usage="
dhprompt [-h] [-e] [-l] [-L <filename>] [-s]
  -e  show dhprompt environment
  -h  show this help text
  -l  show log directory
  -L  view log files using 'less -N -R'
  -s  switch simple/full
  "

  while getopts 'lhesL:' option; do
    case "$option" in
      h) echo "$usage"
         ;;
      e) __help_show_env
         ;;
      l) echo "-------------------------------------"
         du -h ${__LOG_DIR}
         echo "-------------------------------------"
         find ${__LOG_DIR}/. | sort | sed -e "s#${__LOG_DIR}/./##g"
         ;;
      L) if [[ $OPTARG = *".tgz" ]]; then
           tar -O -zxf ${__LOG_DIR}/${OPTARG} | less -N -R
         else
           less -N -R ${__LOG_DIR}/${OPTARG}
        fi
        ;;
      s) if [ "$__SIMPLE" = "true" ]; then
            __SIMPLE="false"
         else
            __SIMPLE="true"
         fi
         echo "set simple: $__SIMPLE"
         ;;
      *) printf "missing argument for -%s\n" "$OPTARG" >&2
         echo "$usage" >&2
         ;;
    esac
  done
  shift $((OPTIND - 1))
}

# completion
_dhprompt()
{
  local cur=${COMP_WORDS[COMP_CWORD]}
  # echo
  # echo "COMP_WORDS : $COMP_WORDS"
  # echo "COMP_CWORD : $COMP_CWORD"
  # echo "cur        : $cur"
  case "$COMP_CWORD" in
  1)
    COMPREPLY=( $(compgen -W "-h -e -l -L -s" -- $cur) )
    ;;
  2)
    if [ "${COMP_WORDS[1]}" = "-L" ]; then
        COMPREPLY=( $(compgen -W "$(find ${__LOG_DIR}/. | sort | sed -e "s#${__LOG_DIR}/./##g")" -- $cur) )
    else
        COMPREPLY=( $(compgen -W "$(ls)" -- $cur) )
    fi
    ;;
  *)
    COMPREPLY=( $(compgen -W "$(ls)" -- $cur) )
    ;;
  esac
}

complete -F _dhprompt dhprompt


__help_show_env() {
 cat << EOT 
# dhprompt environments
[notification]
banner: $__DHPROMPT_BANNER

[hostname / username]
short hostname        : $__SHORTHOST
short hostname length : $__SHORTHOST_CHAR
short username        : $__SHORTUSER
short username length : $__SHORTUSER_CHAR

[simple]
simple prompt : $__SIMPLE

[git enchanement]
fetch check  : $__FETCH_CHECK
fetch branch : $__FETCH_BRANCH

[return code kaomoji]
kamoji show        : $__GOOD_KAOMOJI_SHOW
good kaomoji       : $__GOOD_KAOMOJI
bad kaomoji random : $__BAD_KAOMOJI_RANDOM
bad kaomoji list   : $__BAD_KAOMOJI

[network]
check network        : $__CHECK_NW
short network name   : $__SHORTNW
short network length : $__SHORTNW_CHAR

[date]
date enabled : $__DATE
date format  : $__DATE_FMT
show proxy   : $__SHOW_PROXY

[screen]
show screen session: $__SHOW_SCREEN_SESSIONS

[etc]
cache githome: $__CACHE_GITHOME
EOT

}

BOLD="\[\033[1m\]"
RED="\[\033[1;31m\]"
GREEN="\[\e[32;1m\]"
BLUE="\[\e[34;1m\]"
YELLOW="\[\e[33;1m\]"
CYAN="\[\e[36;1m\]"
VIOLET="\[\e[35;1m\]"
OFF="\[\033[m\]"

__dhprompt () {
    {
    EXITSTATUS="$?" >/dev/null 2>&1

    stash_xtrace
    set +x

    # Logging Command
    if [ -n "${__AUTO_LOGGING}" ];then
      mkdir -p "${__LOG_DIR}/${__LOG_NAME_PREFIX}"
      echo ${previous_command} >> ${__LOG_FILE_COMMAND}
    fi

    if [ "$__SIMPLE" == "true" ];then
      PS1="$(basename $(pwd)) ${__ISROOT} "
      PS2="${BOLD}>${OFF} "
      return
    fi

    if [ "$__DATE" == "true" ];then
        __NOW=`date +"${__DATE_FMT}"`" "
    else
        __NOW=""
    fi

    if [ "${previous_command}" = "__dhprompt" ]; then
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

    if [ "${__AUTO_SIZING}" = "true" ]; then
        auto_resize
    fi
    set_username
    set_hostname

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
    # PROMPT="\n[last: ${timer_show}s]\n"
    PROMPT="\n(${previous_command}(${EXITSTATUS}))\n"
    PROMPT="${PROMPT}$$ [${RANDCOLOR}${__SHORTUSERNAME}${OFF}@${RANDCOLOR}${__SHORTHOSTNAME}${OFF}(${__SHORTNWNAME})] ${YELLOW}${DIRPATH}${OFF}"

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

        # check git managed user
        __gituser=$(ls -ld .git/index | awk '{print $3}') >/dev/null 2>&1
        if [ "$__gituser" != "$USER" ];then
            echo "dhprompt (w): git index has '$__gituser' persmission "
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
        PS1="${PROMPT}${PROXYVAR}${__PYENV_MESSAGE} ${BOLD}${GREEN}${__GOOD_KAOMOJI[0]}${OFF}$(__git_ps1) ${__ISROOT} \n${__NOW}${YELLOW}\W${OFF} ${__ISROOT} "
      else
        PS1="${PROMPT}${PROXYVAR}${__PYENV_MESSAGE}${OFF}$(__git_ps1) ${__ISROOT} \n${__NOW}${YELLOW}\W${OFF} ${__ISROOT} "
      fi
    else
      if [ "$__BAD_KAOMOJI_RANDOM" == "true" ];then
        __BAD_KAOMOJI_SHOW=${__BAD_KAOMOJI[${__ARRAY_RAND}]}
      else
        __BAD_KAOMOJI_SHOW=${__BAD_KAOMOJI[0]}
      fi

      # PS1="${PROMPT}${PROXYVAR}${BOLD}${RED}:(${OFF}$(__git_ps1) ${__ISROOT} "
      PS1="${PROMPT}${PROXYVAR}${__PYENV_MESSAGE}${BOLD}${RED} ${__BAD_KAOMOJI_SHOW}${OFF}$(__git_ps1) ${__ISROOT} \n${__NOW}${YELLOW}\W${OFF} ${__ISROOT} "
    fi

    PS2="${BOLD}>${OFF} "
    if [ "${previous_command}" != "__dhprompt" ]; then
        echo
        echo "(command: ${previous_command})"
    else
        PS1="${__NOW}${YELLOW}\W${OFF} ${__ISROOT} "
    fi


    case "${CURRENT_XTRACE}" in
        *x* )
            set -x
            ;;
        *)
            ;;
    esac
    CURRENT_XTRACE=""

    } > ${__OUTPUT_TARGET} 2>&1

    screen_settitle $(echo -n ${previous_command}| awk '{print $1}')
}

# ppid が script なら起動済み
if [ -n "${__AUTO_LOGGING}" -o -n "${LOGGING_ONESHOT}" ];then
  CURRENT_LOGGING=$(recursive_script $$)
  if [ 0 != "$CURRENT_LOGGING" ];then
    if [ -n "${__DHPROMPT_BANNER}" ];then
      echo " *** dhprompt notice ***"
      echo " - don't 'tail -f LOGFILE', write and read are never end"
      echo
    fi
    mkdir -p "${__LOG_DIR}/${__LOG_NAME_PREFIX}"
    script -f -a ${__LOG_FILE_STD} && exit
  fi
fi

enable_terminal_logging () {
    LOGGING_ONESHOT="true"
}

__compress_log () {
  __LOG_NAME_PREFIX="$(date +${__LOG_FILE_DATE_FORMAT_PREFIX})"
  for i in $(ls ${__LOG_DIR} |grep -v ${__LOG_NAME_PREFIX}| grep -v tgz 2>/dev/null)
  do
    if [ -d ${__LOG_DIR}/${i} ];then
      for fc in $(ls ${__LOG_DIR}/${i}/*-command.log 2>/dev/null)
      do
        echo "=== ${fc} ===" >> ${__LOG_DIR}/${i}/command.log
        cat ${fc} >> ${__LOG_DIR}/${i}/command.log
        rm -rf ${fc}
      done

      for fs in $(ls ${__LOG_DIR}/${i}/*-std.log 2>/dev/null)
      do
        echo "=== ${fs} ===" >> ${__LOG_DIR}/${i}/stdout.log
        # trim ansi and VT100 control characters
        cat ${fs} | sed -s 's/\x1b\[[0-9;]*[a-zA-Z]//g' | sed -s 's/\x1b\[\[[0-9;]*[a-zA-Z]//g'| sed -s 's/\x1b\[?[0-9]*h//g' | sed -s 's/\x1b\[?[0-9]*l//g' | sed -s 's/\x1b[\=|\>]//g' | sed -s 's/\x1b\[?[0-9]*//g' | sed -s 's/\x0d//g' | sed -s 's/\x1bM//g' | sed -s 's/\x1b[0-9]*//g' | sed -s 's/\x07//' >> ${__LOG_DIR}/${i}/stdout.log
        rm -rf ${fs}
      done

      # if process is exists, no tar no rm
      ps -eo pid,comm,cmd |grep "[s]cript -f -a ${__LOG_DIR}/${i}/" >/dev/null 2>&1
      if [ $? != 0 ];then
        tar zcvf ${__LOG_DIR}/${i}.tgz -C ${__LOG_DIR} ./${i}
        rm -rf ${__LOG_DIR}/${i}
      fi
    fi
  done
} >/dev/null 2>&1

echo -n "log compressing... "
__compress_log
echo "done"


PROMPT_COMMAND="__dhprompt"
# PROMPT_COMMAND="echo -ne \033k\033\0134\033k;__dhprompt"
# PROMPT_COMMAND="timer_stop; __dhprompt"

function screen_settitle() {
    if [ -n "$STY" ] ; then
        # We are in a screen session
        printf "\033k%s\033\\" "$@"
        screen -X eval "at \\# title $@" "shelltitle $@"
    else
        printf "\033]0;%s\007" "$@"
    fi
}

trap '{ stash_xtrace; previous_command=$this_command; this_command=$BASH_COMMAND; } > ${__OUTPUT_TARGET} 2>&1' DEBUG > /dev/null 2>&1

