set -ue

local_uid=${LOCAL_UID:-1000}
local_gid=${LOCAL_GID:-1000}

local_username=${LOCAL_USERNAME:-railsuser}
local_groupname=${LOCAL_GROUPNAME:-railsgroup}

if getent group $local_gid > /dev/null; then
  grp=$(getent group $local_gid | cut -d: -f1);
else
  groupadd -g $local_gid $local_groupname;
  grp=$local_groupname;
fi

if getent passwd $local_uid > /dev/null; then
  user=$(getent passwd $local_uid | cut -d: -f1);
else
  useradd -m -u $local_uid -g "$grp" $local_username;
  user=$local_username;
fi

mkdir -p /etc/sudoers.d/

echo "${user} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${user}"

chmod 0440 "/etc/sudoers.d/${user}"
