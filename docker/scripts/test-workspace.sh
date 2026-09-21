#!/usr/bin/env bash
set -eo pipefail

source /opt/ros/humble/setup.bash
cd /workspaces/nlp-pnp-robotic-arm

if [[ ! -f install/setup.bash ]]; then
  colcon build --symlink-install
fi

source install/setup.bash
set -u
colcon test --event-handlers console_direct+ "$@"
colcon test-result --verbose
