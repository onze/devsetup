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
if [[ -z "$TARGET_USER" ]] ; then
    IS_ON_TARGET="yes"
fi

if [[ -z $IS_ON_TARGET ]] ; then
echo "##########################################"
echo "################################ LOCAL RUN on $HOSTNAME"
echo "##########################################"
scp -i "$IDENTITY_FILE" "$IDENTITY_FILE" $TARGET_USER@$TARGET_HOST:~/.ssh/id_rsa
scp -i "$IDENTITY_FILE" "$IDENTITY_FILE.pub" $TARGET_USER@$TARGET_HOST:~/.ssh/id_rsa.pub
scp -i "$IDENTITY_FILE" "$BASH_SOURCE" $TARGET_USER@$TARGET_HOST:~/deploy.sh
# ssh -i "$IDENTITY_FILE" $TARGET_USER@$TARGET_HOST ./deploy.sh
else
echo "##########################################"
echo "############################### REMOTE RUN on $HOSTNAME"
echo "##########################################"
eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa
sudo apt install -y git
mkdir -p ~/libs
git clone git@github.com:onze/devsetup.git ~/libs/devsetup
echo "source ~/libs/devsetup/bashrc_common" >> ~/.bashrc
source ~/libs/devsetup/bashrc_common
mkdir ~/.config/i3 && ln -s ~/libs/devsetup/home/.config/i3/config ~/.config/i3/config

update && upgrade -y && autoremove

# install docker
i -y ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
update
i -y docker-ce trash-cli htop locate python3-pip

fi
