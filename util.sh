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

tell () {
  if [ -z ${2+x} ]
  then
    echo ""
  fi
  echo -e "${BLD}$1${OFF}"
}

ask () {
  if [ -z ${3+x} ]
  then
    echo ""
  fi
  echo -en "${BLD}$2${OFF}(${!1}): ${BLD}"; read $1; echo -en ${OFF}
}

option () {
  echo -e "${IND}${BLD}$1)${OFF} $2"
}

input () {
  echo ""
  echo -en "${IND}${2:-"Enter choice:"} ${BLD}"; read $1; echo -en ${OFF}
}

awk_replace='{
    while (match($0, /\${[^}]+}/)) {
        search = substr($0, RSTART + 1, RLENGTH - 2)
        $0 = substr($0, 1, RSTART - 1)   \
             ENVIRON[search]             \
             substr($0, RSTART + RLENGTH)
    }
    print
}'
