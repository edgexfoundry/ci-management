#!/bin/bash

# vim: sw=4 ts=4 sts=4 et :

# force any errors to cause the script and job to end in failure
set -xeu -o pipefail

rh_changes() {
    echo "---> RH changes"
    # Following directions from 
    # https://docs.docker.com/engine/installation/linux/docker-ce/centos/

    # remove old docker
    yum remove -y docker docker-common docker-selinux docker-engine

    # set up the repository
    yum install -y yum-utils device-mapper-persistent-data lvm2
    yum-config-manager --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
    yum clean -y metadata

    # install docker and enable it
    echo "---> Installing docker"
    yum install -y docker-ce supervisor bridge-utils
    systemctl enable docker

    # configure docker networking so that it does not conflict with LF
    # internal networks
    cat <<EOL > /etc/sysconfig/docker-network
# /etc/sysconfig/docker-network
DOCKER_NETWORK_OPTIONS='--bip=10.250.0.254/24'
EOL

    # configure docker daemon to listen on port 5555 enabling remote
    # managment
    mkdir /etc/docker
    touch /etc/docker/daemon.json
    cat <<EOL > /etc/docker/daemon.json
{
"selinux-enabled": true,
"hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:5555"]
}
EOL

    # Install python dependencies
    yum install -y python-{devel,virtualenv,setuptools,pip}

    # Install docker-compose per https://docs.docker.com/compose/install/#install-compose
    curl -o /usr/local/bin/docker-compose -L "https://github.com/docker/compose/releases/download/1.17.1/docker-compose-$(uname -s)-$(uname -m)"
    chmod +x /usr/local/bin/docker-compose
    docker-compose -v
}

ubuntu_changes() {
    echo "---> Ubuntu changes"
}

OS=$(/usr/bin/facter operatingsystem)
case "$OS" in
    CentOS|Fedora|RedHat)
        rh_changes
    ;;
    Ubuntu)
        ubuntu_changes
    ;;
    *)
        echo "${OS} has no configuration changes"
    ;;
esac

echo "***************************************************"
echo "*   PLEASE RELOAD THIS VAGRANT BOX BEFORE USE     *"
echo "***************************************************"
