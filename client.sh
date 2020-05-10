client_root () {
  server_config_filename='./server.conf'

  client_config_filename='./client.conf'
  client_template_filename='./client.template'

  client_prompt_server_filename () {
    server_config_filename_selections=(./*.conf "Other")

    tell "Which server config will this client connect to?"
      for i in "${!server_config_filename_selections[@]}"; do
        option "$(expr $i + 1)" "${server_config_filename_selections[$i]}"
      done
    input answer

    case ${answer,,} in
      "${#server_config_filename_selections[@]}"|custom )
        input server_config_filename "Enter filename:"
      ;;
      *)
        if [ "${answer,,}" -lt "${#server_config_filename_selections[@]}" ]
          then server_config_filename="${server_config_filename_selections[$(expr ${answer,,} - 1)]}"
          else ${FUNCNAME[0]}
        fi
      ;;
    esac

    client_prompt_config_filename
  }

  client_prompt_config_filename () {
    client_config_filename_selections=(./*.conf "./client-$(random).conf" "Other")
    tell "Where should I save this client config? (duplicates will be overriden)"
      for i in "${!client_config_filename_selections[@]}"; do
        option "$(expr $i + 1)" "${client_config_filename_selections[$i]}"
      done
    input answer

    case ${answer,,} in
      "${#client_config_filename_selections[@]}"|custom )
        input client_config_filename "Enter filename:"
      ;;
      *)
        if [ "${answer,,}" -lt "${#client_config_filename_selections[@]}" ]
          then client_config_filename="${client_config_filename_selections[$(expr ${answer,,} - 1)]}"
          else ${FUNCNAME[0]}
        fi
      ;;
    esac

    client_prompt_template_filename
  }

  client_prompt_template_filename () {
    client_template_filename_selections=(./*.template "Other")

    tell "Which client template should I use?"
    for i in "${!client_template_filename_selections[@]}"; do
      option "$(expr $i + 1)" "${client_template_filename_selections[$i]}"
    done
    input answer

    case ${answer,,} in
      "${#client_template_filename_selections[@]}"|custom )
        input client_template_filename "Enter filename:"
      ;;
      *)
        if [ "${answer,,}" -lt "${#client_template_filename_selections[@]}" ]
          then client_template_filename="${client_template_filename_selections[$(expr ${answer,,} - 1)]}"
          else ${FUNCNAME[0]}
        fi
      ;;
    esac

    client_prompt_variables
  }

  client_prompt_variables () {
    ask CLIENT_ADDRESS "What's the clients's IP address?"
    ask CLIENT_PORT "What port should the server listen on?" false
    ask CLIENT_DNS "What DNS server should this client use?" false
    ask CLIENT_ALLOWED_IPS "What IP address ranges should this client tunnel?" false

    client_prompt_variables_private_key () {
      tell "Do you already have a private key to use?" false
        option 1 "No - generate one for me"
        option 2 "Yes"
      input answer

      case ${answer,,} in
        1|n )
          CLIENT_PRIVATE_KEY=$(wg genkey)
        ;;
        2|y )
          ask CLIENT_PRIVATE_KEY "Enter your private key"
        ;;
        *)
          ${FUNCNAME[0]}
        ;;
      esac
    }

    client_prompt_variables_private_key

    client_prompt_gen_config
  }

  client_prompt_gen_config () {
    server_config=$(cat $server_config_filename)

    SERVER_ADDRESS=$(grep -Po 'Address\s?=\s?\K(.+)' $server_config_filename)
    SERVER_PORT=$(grep -Po 'ListenPort\s?=\s?\K(.+)' $server_config_filename)
    SERVER_ENDPOINT=$(grep -Po '#\s?Electrician-ServerEndpoint:\s?\K(.+)' $server_config_filename)
    SERVER_PRIVATE_KEY=$(grep -Po 'PrivateKey\s?=\s?\K(.+)' $server_config_filename)

    SERVER_PUBLIC_KEY=$(echo $SERVER_PRIVATE_KEY | wg pubkey)

    variables=(
      CLIENT_ADDRESS
      CLIENT_PRIVATE_KEY
      CLIENT_PORT
      CLIENT_DNS
      SERVER_PUBLIC_KEY
      SERVER_ENDPOINT
      SERVER_PORT
      CLIENT_ALLOWED_IPS
    )
    args=""
    args_display=""

    for i in "${variables[@]}"
      do
         args="$args $i=\"${!i}\""
         args_display="$args_display $i=\"${PPL}${!i}${OFF}\""
    done

    cmd="$args perl -pe 's/\\\$\{([^\}]+)}/\$ENV{\$1}/g' $client_template_filename"
    result="$(env -i bash -c "$cmd")"

    cmd_display="$args_display perl -pe 's/\\\$\{([^\}]+)}/\$ENV{\$1}/g' $client_template_filename"
    result_display="$(env -i bash -c "$cmd_display")"

    echo -e "\n$result_display"

    display_qr () {
      qrencode -t ansiutf8 "$result"
    }

    tell "What would you like to do with the client config?"
      option 1 "Show QR code"
      option 2 "Show QR code and save to $client_config_filename"
      option 3 "Only save to $client_config_filename"
    input answer

    case ${answer,,} in
      1 )
        display_qr
        root
      ;;
      2 )
        display_qr
        echo "$result" > $client_config_filename
        root
      ;;
      3 )
        echo "$result" > $client_config_filename
        root
      ;;
      *)
        client_prompt_variables
      ;;
    esac



  }

  client_prompt_server_filename
}
