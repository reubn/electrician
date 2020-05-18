client_root () {
  server_config_filename='./server.conf'

  client_config_filename='./client.conf'
  client_template_filename='./client.template'

  client_prompt_server_filename () {
    server_config_filename_selections_raw=()
    shopt -s nullglob
    for location in "${WG_SERVER_CONFIG_LOCATIONS[@]}"; do
      for file in $location; do
        server_config_filename_selections_raw+=( "$file" )
      done
    done

    server_config_filename_selections=()
    for file in "$(printf "%s\n" "${server_config_filename_selections_raw[@]}" | sort -u)"; do
      server_config_filename_selections+=( $file )
    done

    server_config_filename_selections+=( "Other" )

    tell "📝  Which ${YLW}server${OFF} config will this ${BLU}client${OFF} connect to?"
      for i in "${!server_config_filename_selections[@]}"; do
        option "$(expr $i + 1)" "$(colourTerms "${server_config_filename_selections[$i]}")"
      done
    input answer

    case ${answer,,} in
      "${#server_config_filename_selections[@]}"|custom )
        input server_config_filename "Enter path:"
      ;;
      *)
        if [ "${answer,,}" -lt "${#server_config_filename_selections[@]}" ]
          then server_config_filename="${server_config_filename_selections[$(expr ${answer,,} - 1)]}"
          else ${FUNCNAME[0]}
        fi
      ;;
    esac

    SERVER_ADDRESS=$(grep -Po 'Address\s?=\s?\K(.+)' $server_config_filename)
    SERVER_PORT=$(grep -Po 'ListenPort\s?=\s?\K(.+)' $server_config_filename)
    SERVER_ENDPOINT=$(grep -Po '#\s?Electrician-ServerEndpoint:\s?\K(.+)' $server_config_filename)
    SERVER_PRIVATE_KEY=$(grep -Po 'PrivateKey\s?=\s?\K(.+)' $server_config_filename)

    SERVER_PUBLIC_KEY=$(echo $SERVER_PRIVATE_KEY | wg pubkey)


    client_prompt_variables
  }

  client_prompt_variables () {
    ask CLIENT_ADDRESS "🔢  What's the ${BLU}client's${OFF} WireGuard IP address?" "$(_UNSAFE_stripLastOctect $SERVER_ADDRESS)"
    # ask CLIENT_PORT "💯  What port will the ${BLU}client${OFF} listen on?"
    ask CLIENT_DNS "🌍  What DNS server should this ${BLU}client${OFF} use?" "$(_UNSAFE_stripCIDR $SERVER_ADDRESS)"
    ask CLIENT_ALLOWED_IPS "🔢  What IP address ranges should this ${BLU}client${OFF} tunnel?" "0.0.0.0, ::/0"

    client_prompt_variables_private_key () {
      tell "🔐  Do you already have a ${BLU}client${OFF} private key to use?" false
        option 1 "❌  No - hook me up"
        option 2 "✅  Yes"
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

    client_prompt_template_filename
  }

  client_prompt_template_filename () {
    client_template_filename_selections_raw=()
    shopt -s nullglob
    for location in "${WG_CLIENT_TEMPLATE_LOCATIONS[@]}"; do
      for file in $location; do
        client_template_filename_selections_raw+=( "$file" )
      done
    done

    client_template_filename_selections=()
    for file in "$(printf "%s\n" "${client_template_filename_selections_raw[@]}" | sort -u)"; do
      client_template_filename_selections+=( $file )
    done

    client_template_filename_selections+=( "Other" )

    tell "📄  Which ${BLU}client${OFF} template should I use?"
    for i in "${!client_template_filename_selections[@]}"; do
      option "$(expr $i + 1)" "$(colourTerms "${client_template_filename_selections[$i]}")"
    done
    input answer

    case ${answer,,} in
      "${#client_template_filename_selections[@]}"|custom )
        input client_template_filename "Enter path:"
      ;;
      *)
        if [ "${answer,,}" -lt "${#client_template_filename_selections[@]}" ]
          then client_template_filename="${client_template_filename_selections[$(expr ${answer,,} - 1)]}"
          else ${FUNCNAME[0]}
        fi
      ;;
    esac

    client_prompt_gen_config
  }

  client_prompt_gen_config () {
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

    tell "📝  What would you like to do with the ${BLU}client${OFF} config?"
      option 1 "🔳     Show QR code"
      option 2 "🔳  💾  Show QR code and Save"
      option 3 "💾     Save Only"
    input answer

    case ${answer,,} in
      1 )
        display_qr
      ;;
      2 )
        client_prompt_config_filename
        display_qr
        echo "$result" > $client_config_filename
      ;;
      3 )
        client_prompt_config_filename
        echo "$result" > $client_config_filename
      ;;
      *)
        ${FUNCNAME[0]}
      ;;
    esac

    tell "📝  Do you want to add this ${BLU}client${OFF} to $server_config_filename?"
      option 1 "✅  Yes"
      option 2 "❌  No"
    input answer

    case ${answer,,} in
      1 )
        client_prompt_gen_server_config_template_filename
      ;;
      *)
        root
      ;;
    esac
  }

  client_prompt_config_filename () {
    client_config_filename_selections_raw=()
    shopt -s nullglob
    for location in "${WG_CLIENT_CONFIG_LOCATIONS[@]}"; do
      for file in $location; do
        client_config_filename_selections_raw+=( "$file" )
      done
    done

    client_config_filename_selections=()
    for file in "$(printf "%s\n" "${client_config_filename_selections_raw[@]}" | sort -u)"; do
      client_config_filename_selections+=( $file )
    done

    client_config_filename_selections+=( "Other" )

    tell "📝  Where should I save this ${BLU}client${OFF} config?"
      for i in "${!client_config_filename_selections[@]}"; do
        option "$(expr $i + 1)" "$(colourTerms "${client_config_filename_selections[$i]}")"
      done

    tell "⚠️  File will be overriden!"

    input answer

    case ${answer,,} in
      "${#client_config_filename_selections[@]}"|custom )
        input client_config_filename "Enter path:"
      ;;
      *)
        if [ "${answer,,}" -lt "${#client_config_filename_selections[@]}" ]
          then client_config_filename="${client_config_filename_selections[$(expr ${answer,,} - 1)]}"
          else ${FUNCNAME[0]}
        fi
      ;;
    esac
  }

  client_prompt_gen_server_config_template_filename () {
    client_server_config_template_filename_selections_raw=()
    shopt -s nullglob
    for location in "${WG_CLIENT_SEVER_TEMPLATE_LOCATIONS[@]}"; do
      for file in $location; do
        client_server_config_template_filename_selections_raw+=( "$file" )
      done
    done

    client_server_config_template_filename_selections=()
    for file in "$(printf "%s\n" "${client_server_config_template_filename_selections_raw[@]}" | sort -u)"; do
      client_server_config_template_filename_selections+=( $file )
    done

    client_server_config_template_filename_selections+=( "Other" )

    tell "📄  Which ${BLU}client${OFF} ${YLW}server${OFF} template should I use?"
    for i in "${!client_server_config_template_filename_selections[@]}"; do
      option "$(expr $i + 1)" "$(colourTerms "${client_server_config_template_filename_selections[$i]}")"
    done
    input answer

    case ${answer,,} in
      "${#client_server_config_template_filename_selections[@]}"|custom )
        input client_server_config_template_filename "Enter path:"
      ;;
      *)
        if [ "${answer,,}" -lt "${#client_server_config_template_filename_selections[@]}" ]
          then client_server_config_template_filename="${client_server_config_template_filename_selections[$(expr ${answer,,} - 1)]}"
          else ${FUNCNAME[0]}
        fi
      ;;
    esac

    client_prompt_gen_server_config
  }

  client_prompt_gen_server_config () {
    CLIENT_PUBLIC_KEY=$(echo $CLIENT_PRIVATE_KEY | wg pubkey)

    variables=(
      CLIENT_ADDRESS
      CLIENT_PUBLIC_KEY
    )
    args=""
    args_display=""

    for i in "${variables[@]}"
      do
         args="$args $i=\"${!i}\""
         args_display="$args_display $i=\"${PPL}${!i}${OFF}\""
    done

    cmd="$args perl -pe 's/\\\$\{([^\}]+)}/\$ENV{\$1}/g' $client_server_config_template_filename"
    result="$(env -i bash -c "$cmd")"

    cmd_display="$args_display perl -pe 's/\\\$\{([^\}]+)}/\$ENV{\$1}/g' $client_server_config_template_filename"
    result_display="$(env -i bash -c "$cmd_display")"

    echo -e "\n$result_display"

    tell "💾  Would you like to append this to $server_config_filename?"
      option 1 "✅  Yes"
      option 2 "❌  No"
    input answer

    case ${answer,,} in
      1 )
        echo -e "\n$result" >> "$server_config_filename"
        tell "👌  Done"
      ;;
    esac

    root
  }

  client_prompt_server_filename
}
