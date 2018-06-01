#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -o pipefail

# Modify selinux policy to allow doc builder docker container to write
# files to Jenkins minion host.

cat >>mysphinx.te <<EOL
module mysphinx 1.1;

require {
    type user_home_t;
    type svirt_lxc_net_t;
    class dir { add_name create remove_name write };
    class file { create open read rename getattr setattr write };
}

#============= svirt_lxc_net_t ==============
allow svirt_lxc_net_t user_home_t:dir { add_name create remove_name write };
allow svirt_lxc_net_t user_home_t:file { create open read rename setattr
getattr write };
EOL

sudo checkmodule -M -m -o mysphinx.mod mysphinx.te
sudo semodule_package -o mysphinx.pp -m mysphinx.mod
sudo semodule -i mysphinx.pp
