# Prevent doublesourcing
if [ -z "$USERMOTDSOURCED" ]; then
  USERMOTDSOURCED="Y"
  if test -d "$HOME"; then
    if test ! -e "$HOME"/.hackeros/disable-motd; then
      if test -x "/usr/libexec/hackeros-motd"; then
        /usr/libexec/ublue-motd
      elif test -s "/etc/user-motd"; then
        cat /etc/user-motd
      fi
    fi
  fi
fi

?
