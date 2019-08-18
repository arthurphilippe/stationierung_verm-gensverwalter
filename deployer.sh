#!/bin/bash

set -e

if [[ "$1" == "new" ]]; then
	TO_CLONE=$2
	WHERE_TO_CLONE=$3

	if [[ -z $TO_CLONE ]] || [[ -z $WHERE_TO_CLONE ]]; then
		echo "usage: $0 $1 ssh_repo_to_clone destination"
		exit 1
	fi

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
elif [[ "$1" == "pull" ]]; then
	if [[ ! -f ./.id_rsa_deploy ]]; then
		echo "Deployment's ssh-key not found. Re-clone with \"$0 new\" to setup."
		exit 1
	fi
	echo ":: Preparing ssh-agent."

	eval `ssh-agent` > /dev/null

	ssh-add ./.id_rsa_deploy

	echo " -> Ready."
	echo
	echo ":: Pulling repository"
	git fetch --all
	git reset --hard $2

	echo
	echo ":: Stopping ssh-agent"

	if [ ${SSH_AGENT_PID+1} == 1 ]; then
		ssh-add -D
		ssh-agent -k > /dev/null 2>&1
	fi

	echo " -> Complete!"
else
	echo "usage: $0 [new|pull]  \"additional arguments\""
	exit 1
fi
