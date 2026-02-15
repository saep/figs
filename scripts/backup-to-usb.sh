#!/usr/bin/env bash

if [ "$(id -u)" != "1000" ]; then
    echo 'Unexpected user id: ' "$(id -u)" '!= 1000'
    exit 1
fi

if [[ -z "$1" ]]; then
    echo "No mount point for the usb drive given"
    exit 1
fi

mountPoint="$1"

if ! mount | rg " ${mountPoint} " 2>&1 >/dev/null || [[ ! -d "$mountPoint" ]]; then
    echo "mount directory is probably not correct: ${mountPoint}"
    exit 1
fi

## BORG BACKUP {{{1
# Setting this, so the repo does not need to be given on the commandline:
export BORG_REPO="${mountPoint}/backup/borg"

# or this to ask an external program to supply the passphrase:
read -p "borg backup password: " -s BORG_PASSPHRASE
/run/media/saep/7747d059-a34c-476f-bc89-06473ef129a4
# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

### Syncthing {{{2
if [ -d "${HOME}/documents" ]; then
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
        ::'documents-{now}'              \
        "${HOME}/documents"

    backup_exit=$?

    info "Pruning repository"

    borg prune                          \
        --list                          \
        --glob-archives 'documents-*'   \
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
if [ -d "${HOME}/.gnupg" ]; then
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
        --glob-archives '{hostname}-*'  \
        --show-rc                       \
        --keep-daily    28              \
        --keep-weekly   4               \
        --keep-monthly  12              \

    prune_exit=$?
else
    prune_exit=0
fi

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

exit ${global_exit}

# vim: foldmethod=marker
