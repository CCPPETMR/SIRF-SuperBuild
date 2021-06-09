#!/bin/bash

# Add local user
# Either use runtime USER_ID:GROUP_ID or fallback 1000:1000

USER_ID=${USER_ID:-9000}
GROUP_ID=${GROUP_ID:-9000}
mainUser=${mainUser:-sirfuser}
OLD_HOME=/home-away
export HOME=/home/$mainUser

if [ -d $HOME ]; then
  cd $HOME
  exec gosu $mainUser "$@"
fi

cd /
# allow docker exec into already started container
[ -d $OLD_HOME ] && mv $OLD_HOME $HOME
cd $HOME

echo "Creating $mainUser:$USER_ID:$GROUP_ID"
# groupadd -g $GROUP_ID -o -f $mainUser
addgroup --quiet --system --gid "$GROUP_ID" "$mainUser"
# useradd --shell /bin/bash -u $USER_ID -o -c "" -M -d $HOME \
#   -g $mainUser -G sudo $mainUser \
#   -p $(echo somepassword | openssl passwd -1 -stdin)
adduser --quiet --system --shell /bin/bash \
  --no-create-home --home /home/"$mainUser" \
  --ingroup "$mainUser" --uid "$USER_ID" "$mainUser"

echo "$mainUser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/"$mainUser"

for i in /opt/* "$HOME"; do
  if [ -d "$i" ]; then
    echo "Updating file permissions for $i"
    chown -R $mainUser:$mainUser "$i"
  fi
done

echo "Switching to $mainUser and executing $@"
exec gosu $mainUser "$@"
