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

# vim: ts=4 sw=4 sts=4 et :

cd /ci-management/jenkins-scripts
chmod +x ./*.sh
./system_type.sh

source /tmp/system_type.sh
./basic_settings.sh
if [ -f "${SYSTEM_TYPE}.sh" ]
then
    ./"${SYSTEM_TYPE}.sh"
fi

# Create the jenkins user last so that hopefully we don't have to deal with
# guard files
./create_jenkins_user.sh
