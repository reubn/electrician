server_root () {

  server_prompt_config_filename () {
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

    tell "📝  Where should I save this ${YLW}server${OFF} config?"
      for i in "${!server_config_filename_selections[@]}"; do
        option "$(expr $i + 1)" "$(colourTerms "${server_config_filename_selections[$i]}")"
      done

    tell "⚠️  File will be overriden!"

    input answer

    case ${answer,,} in
      "${#server_config_filename_selections[@]}"|custom )
        input server_config_filename "./" "Enter path:"
      ;;
      *)
        if [ "${answer,,}" -lt "${#server_config_filename_selections[@]}" ]
          then server_config_filename="${server_config_filename_selections[$(expr ${answer,,} - 1)]}"
          else ${FUNCNAME[0]}
        fi
      ;;
    esac

    server_prompt_template_filename
  }

  server_prompt_template_filename () {
    server_template_filename_selections_raw=()
    shopt -s nullglob
    for location in "${WG_SERVER_TEMPLATE_LOCATIONS[@]}"; do
      for file in $location; do
        server_template_filename_selections_raw+=( "$file" )
      done
    done

    server_template_filename_selections=()
    for file in "$(printf "%s\n" "${server_template_filename_selections_raw[@]}" | sort -u)"; do
      server_template_filename_selections+=( $file )
    done

    server_template_filename_selections+=( "Other" )

    tell "📄  Which ${YLW}server${OFF} template should I use?"
    for i in "${!server_template_filename_selections[@]}"; do
      option "$(expr $i + 1)" "$(colourTerms "${server_template_filename_selections[$i]}")"
    done
    input answer

    case ${answer,,} in
      "${#server_template_filename_selections[@]}"|custom )
        input server_template_filename "Enter path:"
      ;;
      *)
        if [ "${answer,,}" -lt "${#server_template_filename_selections[@]}" ]
          then server_template_filename="${server_template_filename_selections[$(expr ${answer,,} - 1)]}"
          else ${FUNCNAME[0]}
        fi
      ;;
    esac

    server_prompt_variables
  }

  server_prompt_variables () {
    ask SERVER_ADDRESS "🔢  What's the ${YLW}server's${OFF} WireGuard IP address?"
    ask SERVER_PORT "💯  What port should the ${YLW}server${OFF} listen on?"
    ask SERVER_ENDPOINT "🔗  What address will the ${YLW}server${OFF} be accessible at?"

    server_prompt_variables_private_key () {
      tell "🔐  Do you already have a private key you want to use on the ${YLW}server${OFF}?" false
        option 1 "❌  No - hook me up"
        option 2 "✅  Yes"
      input answer

      case ${answer,,} in
        1|n )
          SERVER_PRIVATE_KEY=$(wg genkey)
        ;;
        2|y )
          ask SERVER_PRIVATE_KEY "Enter your private key"
        ;;
        *)
          ${FUNCNAME[0]}
        ;;
      esac
    }

    server_prompt_variables_private_key

    server_prompt_write_config
  }

  server_prompt_write_config () {
    # variables=(SERVER_ADDRESS SERVER_PORT SERVER_PRIVATE_KEY)
    # sed_args=""
    # sed_args_display=""
    #
    # for i in "${variables[@]}"
    #   do
    #      sed_args="$sed_args -e s|\${$i}|${!i}|"
    #      sed_args_display="$sed_args_display -e s|\${$i}|$(escape_color $PPL)${!i}$(escape_color $OFF)|"
    #   done
    #
    # result=$(sed $sed_args $server_template_filename)
    # result_display=$(sed $sed_args_display $server_template_filename)
    #
    # result="${result}\n# Electrician-ServerEndpoint: ${SERVER_ENDPOINT}"
    # result_display="${result_display}\n# Electrician-ServerEndpoint: ${PPL}${SERVER_ENDPOINT}${OFF}"
    #
    # echo -e "\n$result_display"

    variables=(SERVER_ADDRESS SERVER_PORT SERVER_PRIVATE_KEY)
    args=""
    args_display=""

    for i in "${variables[@]}"
      do
         args="$args $i=\"${!i}\""
         args_display="$args_display $i=\"${PPL}${!i}${OFF}\""
    done

    cmd="$args perl -pe 's/\\\$\{([^\}]+)}/\$ENV{\$1}/g' $server_template_filename"
    result="$(env -i bash -c "$cmd")"

    cmd_display="$args_display perl -pe 's/\\\$\{([^\}]+)}/\$ENV{\$1}/g' $server_template_filename"
    result_display="$(env -i bash -c "$cmd_display")"

    result="${result}\n# Electrician-ServerEndpoint: ${SERVER_ENDPOINT}"
    result_display="${result_display}\n# Electrician-ServerEndpoint: ${CYN}${SERVER_ENDPOINT}${OFF}"

    echo -e "\n$result_display"

    tell "📝  Would you like to write this to $server_config_filename?"
      option 1 "✅  Yes"
      option 2 "❌  No"
    input answer

    case ${answer,,} in
      1 )
        echo -e "$result" > $server_config_filename
        tell "👌  Done"

        root
      ;;
      *)
        server_prompt_variables
      ;;
    esac
  }

  server_prompt_config_filename

}
