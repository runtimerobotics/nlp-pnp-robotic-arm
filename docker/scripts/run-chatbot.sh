#!/usr/bin/env bash
set -eo pipefail

source /opt/ros/humble/setup.bash
cd /workspaces/nlp-pnp-robotic-arm

if [[ ! -f install/setup.bash ]]; then
  echo 'Workspace has not been built. Run docker/scripts/build-workspace.sh first.' >&2
  exit 1
fi
source install/setup.bash
set -u

cleanup() {
  kill "${target_pid:-}" "${yolo_pid:-}" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

python3 pick_place_chatbot_ui/target_publisher.py &
target_pid=$!
ros2 run yolov8obb_object_detection yolov8_obb_publisher &
yolo_pid=$!

python3 pick_place_chatbot_ui/cmd_bridge.py
