#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPT_DIR

# user on the target host, that matches the IDENTITY_FILE.
TARGET_USER=$1
# where to deploy.
TARGET_HOST=$2
# path to ssh identity file for the given TARGET_USER on the dst host.
IDENTITY_FILE=$3

IS_ON_TARGET=""
if [[ -e "$TARGET_HOST" ]] ; then
    IS_ON_TARGET="yes"
fi

if [[ -e $IS_ON_TARGET ]] ; then
echo "##########################################"
echo "################################ LOCAL RUN"
echo "##########################################"
scp -i "$IDENTITY_FILE" "$IDENTITY_FILE" $TARGET_USER@$TARGET_HOST:~/.ssh/id_rsa
scp -i "$IDENTITY_FILE" "$IDENTITY_FILE.pub" $TARGET_USER@$TARGET_HOST:~/.ssh/id_rsa.pub
scp -i "$IDENTITY_FILE" "$BASH_SOURCE[0]" $TARGET_USER@$TARGET_HOST:~/
ssh -i "$IDENTITY_FILE" $TARGET_USER@$TARGET_HOST ~/deploy.sh $TARGET_USER '$HOSTNAME'
else
echo "##########################################"
echo "############################### REMOTE RUN"
echo "##########################################"
sudo apt install -y git
mkdir -p ~/libs
git@github.com:onze/devsetup.git ~/libs/devsetup
echo "source ~/libs/devsetup/bashrc_common" >> ~/.bashrc
source ~/libs/devsetup/bashrc_common

update && upgrade -y && autoremove

# install docker
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
i docker trash-cli htop locate python3-pip

fi
