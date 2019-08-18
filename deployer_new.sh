#!/bin/bash

set -e

if [[ -z $1 ]] || [[ -z $2 ]]; then
	echo "Usage: $0 ssh_repo_to_clone destination"
	exit 1
fi

TO_CLONE=$1
WHERE_TO_CLONE=$2

if [[ -d $WHERE_TO_CLONE ]]; then
	echo "error: directory ${WHERE_TO_CLONE} exists."
	exit 1
fi

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

echo ":: Stopping ssh-agent"

if [ ${SSH_AGENT_PID+1} == 1 ]; then
	ssh-add -D
	ssh-agent -k > /dev/null 2>&1
fi


echo " -> Complete!"
echo
echo "notes:"
echo "- update the repository using ./pull.sh from its root."
echo "- you can add \".id_rsa_deploy*\" to \".gitignore\" "
