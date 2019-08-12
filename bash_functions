#   extract:  Extract most know archives with one command
#   ---------------------------------------------------------
   
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

function extract() {
 if [ -z "$1" ]; then
    # display usage if no parameters given
    echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
    echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
 else
    for n in "$@"
    do
      if [ -f "$n" ] ; then
          case "${n%,}" in
            *.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar) 
                         tar xvf "$n"       ;;
            *.lzma)      unlzma "$n"      ;;
            *.bz2)       bunzip2 "$n"     ;;
            *.cbr|*.rar)       unrar x -ad "$n" ;;
            *.gz)        gunzip "$n"      ;;
            *.cbz|*.epub|*.zip|*.apk|*.xapk)       unzip "$n" -d "${n:0:-4}"    ;;
            *.z)         uncompress "$n"  ;;
            *.7z|*.arj|*.cab|*.cb7|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar)
                         7z x "$n"        ;;
            *.xz)        unxz "$n"        ;;
            *.exe)       cabextract "$n"  ;;
            *.cpio)      cpio -id < "$n"  ;;
            *.cba|*.ace)      unace x "$n"      ;;
            *)
                         echo "extract: '$n' - unknown archive method"
                         return 1
                         ;;
          esac
      else
          echo "'$n' - file does not exist"
          return 1
      fi
    done
fi
}

IFS=$SAVEIFS

#   mkarchive:  compress a directory
#   ---------------------------------------------------------

function mkarchive(){
	if [[ ! -z $1 ]]
		then
			case $1 in
				  bz2)	tar  cvjf  "$2.tar.bz2" -C "$3" . ;;
				  tgz)	tar cvzf   "$2.tar.gz" -C "$3" .  ;;
				  tar)	tar cvf	    "$2.tar"   -C "$3" .  ;;
				  zip)	zip -r "$2".zip "$3" ;;
				  *)    echo "Usage mkarchive Archive-Type [ bz2 | tgz | tar | zip ]  Archive-Name  Target-Directory to Archive ..." ;;
				 esac
     	else
         	echo "Usage mkarchive Archive-Type [ bz2 | tgz | tar | zip ]  Archive-Name  Target-Directory to Archive ..."
     fi	
}


############################


# Creates an archive from given directory

function mktar() { tar cvf  "${1%%/}.tar"     "${1%%/}/"; }
function mktgz() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }
function mktbz() { tar cvjf "${1%%/}.tar.bz2" "${1%%/}/"; }

#######################################
# Makes directory then moves into it

function mkcd {
    mkdir -p -v $1
    cd $1
}

######################
function up(){
  local d=""
  limit=$1
  for ((i=1 ; i <= limit ; i++))
    do
      d=$d/..
    done
  d=$(echo $d | sed 's/^\///')
  if [ -z "$d" ]; then
    d=..
  fi
  cd $d
}

#########################
function findend {
    find . -type f -name \*.${1}
}
################################


#apt-history
function apt-history(){
      case "$1" in
        install)
              cat /var/log/dpkg.log | grep 'install'
              ;;
        upgrade|remove)
              cat /var/log/dpkg.log | grep $1
              ;;
        rollback)
              cat /var/log/dpkg.log | grep upgrade | \
                  grep "$2" -A10000000 | \
                  grep "$3" -B10000000 | \
                  awk '{print $4"="$5}'
              ;;
        *)
              cat /var/log/dpkg.log
              ;;
      esac
      }
 ################################### 
      # apt-add-repository with automatic install/upgrade of the desired package
		# Usage: aar ppa:xxxxxx/xxxxxx [packagename]
		# If packagename is not given as 2nd argument the function will ask for it and guess the default by taking
		# the part after the / from the ppa name which is sometimes the right name for the package you want to install
aar() {
	about 'apt-add-repository with automatic install/upgrade of the desired package'
	group 'misc'
	param '1: The ppa URL'
	param '2: Package name'
	example '$ aar ppa:xxxxxx/xxxxxx [packagename]'
	if [[ -z $1 ]]
		then
			reference aar
	else
		if [ -n "$2" ]; then
			PACKAGE=$2
		else
			read "PACKAGE?Type in the package name to install/upgrade with this ppa [${1##*/}]: "
		fi
		
		if [ -z "$PACKAGE" ]; then
			PACKAGE=${1##*/}
		fi
		
		sudo apt-add-repository $1 && sudo $APT update
		sudo $APT install $PACKAGE
	fi
}


      
###################
# Get weather
function weather() {
  curl -s "wttr.in/$1"
}


#########################
# converts and saves youtube video to mp3
function convert_to_mp3() {
  youtube-dl --extract-audio --audio-format mp3 $1
}

######################
#colour man pages

man() {
    env \
    LESS_TERMCAP_mb=$(printf "\e[1;36m") \
    LESS_TERMCAP_md=$(printf "\e[1;36m") \
    LESS_TERMCAP_me=$(printf "\e[0m") \
    LESS_TERMCAP_se=$(printf "\e[0m") \
    LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
    LESS_TERMCAP_ue=$(printf "\e[0m") \
    LESS_TERMCAP_us=$(printf "\e[1;33m") \
    man "$@"
}
#############################
# Open filetype
# Finds every file in folder whose extension starts with the first parameter passed
# if more than one file of given type is found, it offers a menu
oft () {
  if [[ $# == 0 ]]; then
    echo -n "Enter an extension or partial extension: "
    read extension
  fi
  if [[ $# > 1 ]]; then
    echo "Usage: oft [(partial) file extension]"
    return
  fi
  extension=$1

  ls *.*$extension* > /dev/null
  if [[ $? == 1 ]]; then
    echo "No files matching \"$extension\" found."
    return
  fi
  declare -a fileList=( *\.*$extension* )

  if [[ ${#fileList[*]} -gt 1 ]]; then
    IFS=$'\n'
    PS3='Open which file? '
    select OPT in "Cancel" ${fileList[*]} "Open ALL"; do
      if [ $OPT == "Open ALL" ]; then
        read -n1 -p "Open all matching files? (y/N): "
        [[ $REPLY = [Yy] ]] && $(/usr/bin/xdg-open  ${fileList[*]})
      elif [ $OPT != "Cancel" ]; then
        $(/usr/bin/xdg-open  "$OPT")
      fi
      unset IFS
      break
    done
  else
    $(/usr/bin/xdg-open "${fileList[0]}")
  fi
}

#########################
# Creates executable bash script, or just changes modifiers to
# executable, if file already exists.
mkexecute() {
  echo "make File Executable Or Create New Bash Or Python Script"
  echo ""
  if [[ ! -f "$1" ]]; then
    filename=$(basename "$1")
    extension="${filename##*.}"
    if [[ "$extension" == "py" ]]; then
      echo '#!/usr/bin/env python3' >> "$1"
      echo '#' >> "$1"
      echo "# Usage: $1 " >> "$1"
      echo '# ' >> "$1"
      echo >> "$1"
      echo 'import sys' >> "$1"
      echo 'import re' >> "$1"
      echo >> "$1"
      echo 'def main():' >> "$1"
      echo '    ' >> "$1"
      echo >> "$1"
      echo "if __name__ == '__main__':" >> "$1"
      echo '    main()' >> "$1"
    elif [[ "$extension" == "sh" ]]; then
      echo '#!/bin/bash' >> "$1"
      echo '# Shell Script Template' >> "$1"
      echo "#/ Usage: $1 " >> "$1"
      echo "#/ Description: " >> "$1"
      echo "#/ Options: " >> "$1"
      echo '# ' >> "$1"
      echo "#Colors" >> "$1"
      echo "
normal='\e[0m'
cyan='\e[0;36m'
green='\e[0;32m'
light_green='\e[1;32m'
white='\e[0;37m'
yellow='\e[1;49;93m'
blue='\e[0;34m'
light_blue='\e[1;34m'
orange='\e[38;5;166m'
light_cyan='\e[1;36m'
red='\e[1;31m' 
      " >> "$1"
      echo "function usage() { grep '^#/' "$1" | cut -c4- ; exit 0 ; }" >> "$1"
      echo >> "$1"
      echo "# Logging Functions to log what happend in the script [It's recommended]" >> "$1"
      echo "" >> "$1"
      echo "readonly LOG_FILE=\"/tmp/\$(basename \"\$0\").log\"" >> "$1"
      echo "
    info()    { echo -e \"\$light_cyan[INFO]\$white \$*\$normal\" | tee -a \"\$LOG_FILE\" >&2 ; }
    warning() { echo -e \"\$yellow[WARNING]\$white \$*\$normal\" | tee -a \"\$LOG_FILE\" >&2 ; }
    error()   { echo -e \"\$red[ERROR]\$white \$*\$normal\" | tee -a \"\$LOG_FILE\" >&2 ; }
    fatal()   { echo -e \"\$orange[FATAL]\$white \$*\$normal\" | tee -a \"\$LOG_FILE\" >&2 ; exit 1 ; }
      
      " >> "$1"
      echo '# Stops execution if any command fails.' >> "$1"
      echo 'set -eo pipefail' >> "$1"
      
      echo >> "$1"
      echo "function cleanup() {" >> "$1"
      echo "  # Remove temporary files
    # Restart services
    # ..." >> "$1"
      echo "  echo \"\"" >> "$1"
      echo "}" >> "$1"
      echo >> "$1"
      echo 'function main() {'>> "$1"
      echo "  if [[ \$1 = \"--help\" ]]" >> "$1" 
      echo "	then" >> "$1"
      echo '    expr "$*" : ".*--help" > /dev/null && usage'>> "$1"
      echo '	else' >> "$1"
      echo '    # Some Code Here'   >> "$1"
      echo "    echo \"some code here\"" >> "$1"
      echo "  fi" >> "$1"
      echo "" >> "$1"
      echo "#trap command make sure the cleanup function run to clean any miss created by the script" >> "$1"
      echo >> "$1"
      echo "trap cleanup EXIT" >> "$1"
      echo >> "$1"
      echo '}'>> "$1"
      echo >> "$1"
      echo "#This test is used to execute the main code only when the script is executed directly, not sourced" >> "$1"
      echo "
if [[ \"\${BASH_SOURCE[0]}\" = \"\$0\" ]]; then
    # Main code of the script
      " >> "$1"
      echo 'main "$@"'>> "$1"
       echo "
      info  this is information
      warning  this is warning
      error  this is Error
      fatal  this is Fatal
      " >> "$1"
      echo "fi" >> "$1"
      echo "" >> "$1"
      echo "" >> "$1"
    else
      echo "To give executable permissions To exist file: mkexecute <path/file_name>.<py|sh>"
      echo "To Create new executable: mkexecute <file_name>.<py|sh>"
    fi
  fi
  if [[ ! -z "$1" ]]; then
  chmod u+x "$@"
  else
  true
  fi           
}
#####################3
# Displays wireless networks in range.
wirelessNetworksInRange() {
 sudo iwlist wlp2s0 scan \
    | grep Quality -A2 \
    | tr -d "\n" \
    | sed 's/--/\n/g' \
    | sed -e 's/ \+/ /g' \
    | sort -r \
    | sed 's/ Quality=//g' \
    | sed 's/\/70 Signal level=-[0-9]* dBm Encryption key:/ /g' \
    | sed 's/ ESSID:/ /g'
}
#############################
#List all functions in .bash_functions file
lstfunc(){
  function_name=$1
  
  grep -v '^ ' ~/.bash_functions | sed -n -e '/^.*'"$function_name"'(){/ p' -e '/^.*'"$function_name"'() {/ p'
}
#########################
#quicly get cheat sheet to something (eg: cheatsheet bash)
cheatsheet() {
    # Cheatsheets https://github.com/chubin/cheat.sh
    if [ "$1" == "" ]; then
        echo "Usage ${FUNCNAME[0]} {Someting}"
        echo "eg: ${FUNCNAME[0]} ls"
        
    else
    	curl -L "https://cheat.sh/$1"
    fi
}

##########################

#get cheatsheets from devhints.io website

devhints(){
type wget >/dev/null 2>&1 || { echo >&2 "I require wget but it's not installed."; exit 1; }
type bat >/dev/null 2>&1 || { echo >&2 "I require bat but it's not installed."; exit 1; }

TOOL=${1:?Usage: ${FUNCNAME} <toolname> [--refresh]}
REFRESH=${2:-no}

RAW_MD_URL="https://raw.githubusercontent.com/rstacruz/cheatsheets/master/${TOOL}.md"

CACHE_DIR=$HOME/.hack/
LOCAL_CACHE_FILE=$CACHE_DIR/${TOOL}.md

if [ ! -d $CACHE_DIR ]; then
  mkdir -p $CACHE_DIR
fi

if [ "$REFRESH" == "--refresh" ] || [ ! -e $LOCAL_CACHE_FILE ]; then
  wget -q -O - $RAW_MD_URL | sed -e '/^{: /d' > $LOCAL_CACHE_FILE
fi

if [ -s $LOCAL_CACHE_FILE ]; then
  bat $LOCAL_CACHE_FILE 2>/dev/null
else
  echo No cheat sheet found!
  rm -rf $LOCAL_CACHE_FILE > /dev/null 2>&1
fi
}

