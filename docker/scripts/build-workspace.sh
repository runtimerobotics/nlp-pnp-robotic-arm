#!/usr/bin/env bash
set -eo pipefail

source /opt/ros/humble/setup.bash
set -u
cd /workspaces/nlp-pnp-robotic-arm

# Reconfigure CMake on every image-backed build. This prevents cached Python /
# NumPy include paths from a previous container image breaking ROS interface
# generation after ML dependencies are installed or upgraded.
colcon build --symlink-install --cmake-clean-cache "$@"
