#!/usr/bin/env bash

if [ "$(id -u)" != "1000" ]; then
    echo 'Unexpected user id: ' "$(id -u)" '!= 1000'
    exit 1
fi

case $(hostname) in
    monad)
        mountPoint=/mnt/my_usb
        ;;
    monoid)
        mountPoint=/media/saep/persistence
        ;;
    swaep)
        mountPoint=/run/media/saep/persistence
        ;;
    *)
        echo 'Unknown hostname: ' "$(hostname)"
        exit 1
        ;;
esac

## Mount usb stick {{{1
if [ ! -d "$mountPoint" ]; then
    echo "Please mount the usb stick"
    exit 1
fi
# Ye olde ways!
# if [ ! -e /dev/mapper/my_usb ]; then
#     sudo cryptsetup luksOpen /dev/disk/by-uuid/4cd2375a-e1d2-4690-90f6-1796ed07dac4 my_usb
#     if [ $? -ne 0 ]; then
#         echo Failed to decrypt usb stick
#         exit 1
#     fi
# fi

# if ! mount | grep "${mountPoint}" >/dev/null ; then
#     sudo mount -t ext4 /dev/mapper/my_usb "${mountPoint}"
#     if [ $? -ne 0 ]; then
#         echo Failed to mount usb stick
#         exit 1
#     fi
# fi

## BORG BACKUP {{{1
# Setting this, so the repo does not need to be given on the commandline:
export BORG_REPO="${mountPoint}/backup/borg"

# or this to ask an external program to supply the passphrase:
export BORG_PASSCOMMAND='pass show backup'

# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

### Syncthing {{{2
if [ -d "${HOME}/Documents" ]; then
    info "Starting backup of syncthing documents"

    # Backup the most important directories into an archive named after
    # the machine this script is currently running on:

    borg create                         \
        --verbose                       \
        --filter AME                    \
        --list                          \
        --stats                         \
        --show-rc                       \
        --compression lz4               \
        --exclude-caches                \
        \
        ::'Documents-{now}'              \
        "${HOME}/Documents"

    backup_exit=$?

    info "Pruning repository"

    borg prune                          \
        --list                          \
        --prefix 'Documents-'           \
        --show-rc                       \
        --keep-daily    28              \
        --keep-weekly   4               \
        --keep-monthly  12              \

        prune_exit=$?

    global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

    if [ ${global_exit} -eq 1 ];
    then
        info "Backup and/or Prune finished with a warning"
    fi

    if [ ${global_exit} -gt 1 ];
    then
        info "Backup and/or Prune finished with an error"
    fi
fi

### Host specific {{{2
GNUPG_EXPORT_DIR="${HOME}/.gnupg/exported"
rm -rf "$GNUPG_EXPORT_DIR"
mkdir "$GNUPG_EXPORT_DIR"
gpg -a --export > "${GNUPG_EXPORT_DIR}/pubkeys.asc"
gpg -a --export-secret-keys > "${GNUPG_EXPORT_DIR}/privatekeys.asc"
gpg --export-ownertrust > "${GNUPG_EXPORT_DIR}/otrust.txt"
## To restore gnupg data:
# gpg --import myprivatekeys.asc
# gpg --import mypubkeys.asc
# gpg -K
# gpg -k
# gpg --import-ownertrust otrust.txt

info "Starting backup of host specific folders"

# Backup the most important directories into an archive named after
# the machine this script is currently running on:

borg create                         \
    --verbose                       \
    --filter AME                    \
    --list                          \
    --stats                         \
    --show-rc                       \
    --compression lz4               \
    --exclude-caches                \
                                    \
    ::'{hostname}-{now}'            \
    "$GNUPG_EXPORT_DIR"

backup_exit=$?

info "Pruning repository"

borg prune                          \
    --list                          \
    --prefix '{hostname}-'           \
    --show-rc                       \
    --keep-daily    28              \
    --keep-weekly   4               \
    --keep-monthly  12              \

prune_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))

if [ ${global_exit} -eq 1 ];
then
    info "Backup and/or Prune finished with a warning"
fi

if [ ${global_exit} -gt 1 ];
then
    info "Backup and/or Prune finished with an error"
fi
## BORG BACKUP }}}1

sync

echo 'Unmount stick? (y/N)'
read -r unmount
case $unmount in
    y*)
        if ! sudo umount "$mountPoint" && sudo cryptsetup luksClose my_usb ; then
            echo failure unmounting usb stick
        fi
        ;;
    **)
        ;;
esac

exit ${global_exit}

# vim: foldmethod=marker
