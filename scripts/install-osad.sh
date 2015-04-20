#!/usr/bin/env bash

# Copyright 2015, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

## Shell Opts ----------------------------------------------------------------
set -e -u -x


## Vars ----------------------------------------------------------------------
export OSAD=${OSAD:-"os-ansible-deployment"}
export OSAD_REPO=${OSAD_REPO:-"https://github.com/stackforge/${OSAD}.git"}
export OSAD_BRANCH=${OSAD_BRANCH:-"master"}
export IS_AIO=${IS_AIO:-"no"}

function bootstrap_aio() {
    if [ ! -f /etc/network/interfaces.d/aio_interfaces.cfg ]; then
        # Run the scripts in sub-shells since they check for `dirname ${0}`
        $(scripts/bootstrap-aio.sh)
    fi
}

function bootstrap_ansible() {
    # We need to bootstrap ansible if it's not already been done.
    if [ ! -f /usr/local/bin/openstack-ansible ]; then
        $(scripts/bootstrap-ansible.sh)
    fi
}

# Checkout the branch/tag of OSAD that we want to work with.
pushd /opt
    if [ ! -d "$OSAD" ]; then
        git clone -b $OSAD_BRANCH $OSAD_REPO
    fi
popd

# Do any bootstrapping work
pushd /opt/"${OSAD}"
    if [ "${IS_AIO}" == "yes" ]; then
        bootstrap_aio
    fi
    bootstrap_ansible

    # Provided minimum necessary variables for rpc-extras
    # This will need to account for actual configuration at some point, though.
    cp -R etc/openstack_deploy/ /etc/openstack_deploy
    echo 'rpc_repo_path: /opt/os-ansible-deployment' >> /etc/openstack_deploy/user_extras_variables.yml

    if [ ! -f /etc/openstack_deploy/user_extras_secrets.yml ]; then
        touch /etc/openstack_deploy/user_extras_secrets.yml
    fi
    scripts/pw-token-gen.py --file /etc/openstack_deploy/user_extras_secrets.yml
    bash scripts/run-playbooks.sh
popd
