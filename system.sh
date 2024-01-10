#!/bin/sh

# This script tries to build system configuration based on the current hostname.
#

op=${1:-boot} # boot, switch 
host=${2:-$(hostname)}

if [ -z "$host" ]; then
  echo "No profile host name provied and \$HOST is empty."
  exit 1
fi

case "$op" in
  boot)
    sudo nixos-rebuild --flake ".#${host}" boot
    ;;
  switch)
    sudo nixos-rebuild --flake ".#${host}" switch
    ;;
  *)
    echo "Unknown operation: $op"
    echo "Supported operations are: boot, switch"
    exit 1
    ;;
esac
