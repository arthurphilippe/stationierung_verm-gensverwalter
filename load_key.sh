#!/bin/bash

set -e

echo "note: script has to be run in same-shell mode."
echo "usage: . $0"

echo ":: Starting ssh-agent"

eval `ssh-agent` > /dev/null

echo " -> complete."
echo
echo ":: Adding key"
ssh-add ./.id_rsa_deploy
echo " -> complete."
