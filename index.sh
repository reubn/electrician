#/bin/bash

SCRIPT_VERSION="0.0.1"

. ./util.sh
. ./server.sh
. ./client.sh

echo -e "${PPL}electrician v${SCRIPT_VERSION} - WireGuard Manager${OFF}"

root () {
  tell "What can I help you with?"
    option 1 "Add New Server Config"
    option 2 "Add New Client Config"
    option 3 "Exit"
  input answer

  case ${answer,,} in
    1|s|server)
      server_root
    ;;
    2|c|client)
      client_root
    ;;
    3|exit)
      exit
    ;;
    *)
      ${FUNCNAME[0]}
    ;;
  esac
}

root
