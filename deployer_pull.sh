#!/bin/bash

set -e

echo ":: Preparing ssh-agent."

eval `ssh-agent` > /dev/null

ssh-add ./.id_rsa_deploy

echo " -> Ready."
echo
echo ":: Pulling repository"
git pull $@

echo
echo ":: Stopping ssh-agent"

if [ ${SSH_AGENT_PID+1} == 1 ]; then
	ssh-add -D
	ssh-agent -k > /dev/null 2>&1
fi

echo " -> Complete!"
