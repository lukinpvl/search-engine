#!/bin/sh

set -e

export PROJECT=handy-cell-309908
export REGION=us-central1
export MACHINE_TYPE=n1-standard-2
export NUM_NODES=2
export USE_STATIC_IP=true
export DOMAIN=se-project.tk

cd infra/gitlab/

echo "gitlab/gke_bootstrap_script.sh down"

./gke_bootstrap_script.sh down
