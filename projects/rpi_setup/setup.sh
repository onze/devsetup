#!/usr/bin/env bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=`realpath ${SCRIPT_DIR}/../..`

case "$1" in
  --remote)
    REMOTE_MODE=1
    TARGET_HOST=$2
    ;;
  --local)
    LOCAL_MODE=1
    ;;
  *)
    echo "Usage:"
    echo "$0 --remote TARGET_HOST"
    echo "$0 --local"
    ;;
esac

if [[ $REMOTE_MODE ]]; then
    rsync -P -rvzc --include tags --cvs-exclude --delete ${ROOT_DIR} $USER@$TARGET_HOST:./
    ssh $USER@$TARGET_HOST ./devsetup/projects/rpi_setup/setup.sh --local
elif [[ $LOCAL_MODE ]]; then
    echo 'source ~/devsetup/bash/bashrc_common' >> ~/.bashrc
    sudo apt-get update
    sudo apt-get upgrade -y

    sudo apt-get install -y \
      python3-ipython \
      libcap-dev \
      trash-cli \
      git

    # for software 3d
    sudo apt-get install -y mesa-utils mesa-utils-bin
#         docker.io
#     sudo usermod -a -G docker $USER
    sudo usermod -a -G gpio $USER
    echo "local setup done"
fi




