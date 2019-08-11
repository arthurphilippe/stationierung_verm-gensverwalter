#!/bin/bash

set -e

if [[ -z $1 ]] || [[ -z $2 ]]; then
  echo "Usage: $0 ssh_repo_to_clone destination"
  exit 1
fi

TO_CLONE=$1
WHERE_TO_CLONE=$2

TMP=$(mktemp -d)

ssh-keygen -b 4094 -t rsa -f ${TMP}/.id_rsa_deploy  -q -N ""

echo ":: Deployment key to authorise:"
cat ${TMP}/.id_rsa_deploy.pub

echo -n ":: Hit return to continue..."
read

eval `ssh-agent` > /dev/null

ssh-add ${TMP}/.id_rsa_deploy

git clone $TO_CLONE $WHERE_TO_CLONE

mv ${TMP}/.id_rsa_deploy ${TMP}/.id_rsa_deploy.pub $WHERE_TO_CLONE

echo " -> Complete!"

echo "Note: update the repository using ./pull.sh from its root."
