#!/bin/bash

# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
set -xe

#NOTE: Deploy command

#NOTE: override file
tee /tmp/ranger.yaml << EOF
conf:
  ranger:
    DEFAULT:
      ranger_agent_https_enable: true
      ranger_agent_client_cert_path: '/home/ranger/ord.cert'
  ssh:
    ssh_key:
    ssh_config:
  cert:
    ranger_agent_client_cert:
EOF

#NOTE: Get the over-rides to use
: ${OSH_EXTRA_HELM_ARGS_RANGER:="$(./tools/deployment/common/get-values-overrides.sh ranger)"}

#NOTE: Deploy command
: ${OSH_EXTRA_HELM_ARGS:=""}

helm upgrade --install ranger ./ranger \
  --namespace=openstack \
  --values=/tmp/ranger.yaml \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_RANGER}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

helm status ranger
kubectl delete pods -l application=ranger,release_group=ranger,component=test \
  --namespace=openstack --ignore-not-found
helm test ranger --timeout 900
