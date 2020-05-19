reload_root () {

  reload_prompt_config_path () {
    reload_config_path_selections_raw=()
    shopt -s nullglob
    for location in "${WG_RELOAD_CONFIG_LOCATIONS[@]}"; do
      for file in $location; do
        reload_config_path_selections_raw+=( "$file" )
      done
    done

    reload_config_path_selections=()
    for file in "$(printf "%s\n" "${reload_config_path_selections_raw[@]}" | sort -u)"; do
      reload_config_path_selections+=( $file )
    done

    reload_config_path_selections+=( "Other" )

    tell "🌀  Which ${YLW}server${OFF} config do you want to reload?"
      for i in "${!reload_config_path_selections[@]}"; do
        option "$(expr $i + 1)" "$(colourTerms "${reload_config_path_selections[$i]}")"
      done

    input answer

    case ${answer,,} in
      "${#reload_config_path_selections[@]}"|custom )
        input reload_config_path "$(pwd)/" "Enter path:"
      ;;
      *)
        if [ "${answer,,}" -lt "${#reload_config_path_selections[@]}" ]
          then reload_config_path="${reload_config_path_selections[$(expr ${answer,,} - 1)]}"
          else ${FUNCNAME[0]}
        fi
      ;;
    esac

    reload_config
  }

  confToInterface () {
    echo "$1" | perl -pe 's/^.*\/(.+)\.conf$/$1/g'
  }

  reload_config () {
    reload_config_interface=$(confToInterface "$reload_config_path")

    tell "📝  Would you like to reload interface '$reload_config_interface' from $reload_config_path?"
      option 1 "✅  Yes"
      option 2 "❌  No"

    tell "⚠️  Current WireGuard Connections May Drop!"

    input answer

    case ${answer,,} in
      1 )
        # WireGuard will override config file when taking interface down - wiping changes
        reload_config_path_tmp="$reload_config_path.electriciantmp"

        sudo touch $reload_config_path_tmp
        sudo cp $reload_config_path $reload_config_path_tmp

        sudo wg-quick down $reload_config_path

        sudo cp $reload_config_path_tmp $reload_config_path

        sudo wg-quick up $reload_config_path

        sudo rm $reload_config_path_tmp

        tell "👌  Done"
      ;;
    esac

    root
  }

  reload_prompt_config_path
  }
