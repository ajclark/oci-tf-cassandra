#!/bin/sh

# Mount data disk
sleep 60 && \
 test -z "$(blkid /dev/sdb)" && \
 sudo mkfs.xfs -L data /dev/sdb && \
 sudo mkdir /mnt/data && \
 sudo echo "LABEL=data /mnt/data xfs defaults 0 0" >> /etc/fstab && \
 sudo mount /mnt/data

# Mount the commit disk
test -z "$(blkid /dev/sdc)" && \
 sudo mkfs.xfs -L commit /dev/sdc && \
 sudo mkdir /mnt/commit && \
 sudo echo "LABEL=commit /mnt/commit xfs defaults 0 0" >> /etc/fstab && \
 sudo mount /mnt/commit

# Install BCC tools
sudo dnf install -y bcc-tools

# Install Cassandra
sudo dnf install -y yum-utils
sudo dnf install -y epel-release
sudo dnf config-manager --set-enabled powertools

cat <<EOF > /etc/yum.repos.d/cassandra.repo
[cassandra]
name=Apache Cassandra
baseurl=https://downloads.apache.org/cassandra/redhat/40x/
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://downloads.apache.org/cassandra/KEYS
EOF

sudo dnf update -y
sudo dnf install -y cassandra
sudo systemctl enable cassandra
sudo service cassandra start
