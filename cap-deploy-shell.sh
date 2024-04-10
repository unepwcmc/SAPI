#/bin/bash
mkdir -p ~/.ssh;

cp /run/secrets/host_ssh_key ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519

cp /run/secrets/host_ssh_config ~/.ssh/config
chmod 600 ~/.ssh/config

source /etc/profile.d/rvm.sh
eval "$(ssh-agent -s)"
ssh-add
