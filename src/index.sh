#/bin/bash

SCRIPT_VERSION="0.0.8"

. ./util.sh
. ./conf.sh
. ./server.sh
. ./client.sh
. ./reload.sh

if [[ $EUID -ne 0 ]]; then
   tell "❌  ${RED}This script must be run as root!${OFF}" false
   exit 1
fi


root () {
  tell "What can I help you with?"
    option 1 "🗄  Add New ${YLW}Server${OFF} Config"
    option 2 "👩‍  Add New ${BLU}Client${OFF} Config"
    option 3 "🌀‍  Reload  ${YLW}Server${OFF} Config"
    option 4 "🚪  Exit"
  input answer

  case ${answer,,} in
    1|s|server)
      server_root
    ;;
    2|c|client)
      client_root
    ;;
    3|r|reload)
      reload_root
    ;;
    4|exit)
      exit
    ;;
    *)
      ${FUNCNAME[0]}
    ;;
  esac
}

root
