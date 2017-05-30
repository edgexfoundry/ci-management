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

#######################
# Create Jenkins User #
#######################

OS=$(facter operatingsystem | tr '[:upper:]' '[:lower:]')

useradd -m -s /bin/bash jenkins

# Check if docker group exists
grep -q docker /etc/group
if [ "$?" == '0' ]
then
  # Add jenkins user to docker group
  usermod -a -G docker jenkins
fi

# Check if mock group exists
grep -q mock /etc/group
if [ "$?" == '0' ]
then
  # Add jenkins user to mock group so they can build Int/Pack's RPMs
  usermod -a -G mock jenkins
fi

mkdir /home/jenkins/.ssh
mkdir /w
cp -r /home/${OS}/.ssh/authorized_keys /home/jenkins/.ssh/authorized_keys
# Generate ssh key for use by Robot jobs
echo -e 'y\n' | ssh-keygen -N "" -f /home/jenkins/.ssh/id_rsa -t rsa
chown -R jenkins:jenkins /home/jenkins/.ssh /w
