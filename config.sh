#!/bin/sh

# This script tries to build the home manager derivation based on the current
# hostname and username.  
#
# By default the home manager configuration "user@host" is built. 
# The available configuraitons are specified in flake.nix.

op=${1:-build} # build, install 
host=${2:-$(hostname)}
user=${3:-$USER}

if [ -z "$user" ]; then
  echo "No profile user name provided and \$USER is empty."
  exit 1
elif [ -z "$host" ]; then
  echo "No profile host name provied and \$HOST is empty."
  exit 1
fi

if [ "$WSL_DISTRO_NAME" = "nixos" ] && [ "$(hostname)" = "Monoid" ]; then
  activationPackage=".#homeConfigurations."${user}@nixos-wsl".activationPackage"
else
  activationPackage=".#homeConfigurations."${user}@${host}".activationPackage"
fi


build() {
  if ! nix build \
    --extra-experimental-features 'nix-command flakes' \
    "$activationPackage"; then
      echo "Package ${activationPackage} cannot be build!"
      exit 1
  fi
}

case "$op" in
  build)
    build
    ;;
  install)
    build
    if [ -x "./result/activate" ]; then
      if "./result/activate"; then
        echo "Successfully activated/installed package $activationPackage"
      else
        exit 1
      fi
    else 
      echo "./result/activate has not been generated by the build."
      exit 1
    fi
    ;;
  *)
    echo "Unknown operation: $op"
    echo "Supported operations are: build, install"
    exit 1
    ;;
esac
