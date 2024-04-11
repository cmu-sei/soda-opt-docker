#!/bin/bash

# check that values present for user and group id
if [ "${UID}" -eq "0" ] || [ -z "$GID" ] ; then
    echo "Add -e UID=\$(id -u) -e GID=\$(id -g) to your docker run command."
    exit 1
fi
echo "Changing UID and GID for soda-opt-user to host values."
usermod -d /tmp/home/soda-opt-user soda-opt-user
usermod -u ${UID} soda-opt-user
groupmod -g ${GID} soda-opt-user
usermod -d /home/soda-opt-user soda-opt-user

echo "Setting permissions."
chown -R soda-opt-user:soda-opt-user /home/soda-opt-user

# change user
echo "Changing to soda-opt-user."
su soda-opt-user
