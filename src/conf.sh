WG_SERVER_CONFIG_LOCATIONS=("$(pwd)/*.conf" /etc/wireguard/*.conf /usr/local/etc/wireguard/*.conf)
WG_SERVER_TEMPLATE_LOCATIONS=("$(pwd)/*server.template" /etc/wireguard/*server.template /usr/local/etc/wireguard/*server.template)

WG_CLIENT_CONFIG_LOCATIONS=("$(pwd)/*.conf" /etc/wireguard/*.conf /usr/local/etc/wireguard/*.conf)
WG_CLIENT_TEMPLATE_LOCATIONS=("$(pwd)/*client.template" /etc/wireguard/*client.template /usr/local/etc/wireguard/*client.template)

WG_CLIENT_SEVER_TEMPLATE_LOCATIONS=("$(pwd)/*client-server-entry.template" /etc/wireguard/*client-server-entry.template /usr/local/etc/wireguard/*client-server-entry.template)

WG_RELOAD_CONFIG_LOCATIONS=(/etc/wireguard/*.conf /usr/local/etc/wireguard/*.conf)
