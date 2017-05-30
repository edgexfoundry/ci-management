#!/bin/bash
# @License EPL-1.0 <http://spdx.org/licenses/EPL-1.0>
##############################################################################
# Copyright (c) 2016 The Linux Foundation and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
##############################################################################

case "$(facter operatingsystem)" in
  Ubuntu)
    apt-get update
    ;;
  *)
    # Do nothing on other distros for now
    ;;
esac

IPADDR=$(facter ipaddress)
HOSTNAME=$(facter hostname)
FQDN=$(facter fqdn)

echo "${IPADDR} ${HOSTNAME} ${FQDN}" >> /etc/hosts

#Increase limits
cat <<EOF > /etc/security/limits.d/jenkins.conf
jenkins         soft    nofile          16000
jenkins         hard    nofile          16000
EOF

cat <<EOSSH >> /etc/ssh/ssh_config
Host *
  ServerAliveInterval 60

# we don't want to do SSH host key checking on spin-up systems
Host 10.30.122.*
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOSSH

cat <<EOKNOWN >  /etc/ssh/ssh_known_hosts
github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
EOKNOWN

# vim: sw=2 ts=2 sts=2 et :
