BLD='\e[1m'
IND='   '

BLA='\033[1;30m'
RED='\033[1;31m'
GRN='\033[1;32m'
YLW='\033[1;33m'
BLU='\033[1;34m'
PPL='\033[1;35m'
CYN='\033[1;36m'
WTE='\033[1;37m'

OFF='\033[0m'

escape_color () {
  echo "\\$1"
}

random () {
  cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w ${1:-6} | head -n 1
}

colourTerms () {
  client="${1//client/${BLU}client${OFF}}"
  echo "${client//server/${YLW}server${OFF}}"
}

_UNSAFE_stripLastOctect () {
  echo "$1" | perl -pe 's/\.(\d+)(\/\d+)?$/\./g'
}
_UNSAFE_stripCIDR () {
  echo "$1" | perl -pe 's/\/\d+$//g'
}

tell () {
  if [ -z ${2+x} ]
  then
    echo ""
  fi
  echo -e "${BLD}$1${OFF}"
}

ask () {
  default="${3}"

  echo -en "${BLD}$2${OFF}: ${BLD}"; read -e -i " $default" $1; echo -en ${OFF}
}

option () {
  echo -e "${IND}${BLD}$1)${OFF} $2"
}

input () {
  default="${2}"

  echo ""
  echo -en "${IND}${3:-"Enter choice:"} ${BLD}"; read -e -i " $default" $1; echo -en ${OFF}
}
