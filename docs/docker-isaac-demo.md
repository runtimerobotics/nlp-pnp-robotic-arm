# Docker, Isaac Sim, MoveIt, Perception, and Chatbot Demo

This guide runs the UR5 pick-and-place demo with:

- Isaac Sim 6.0.1 on the host for simulation, cameras, and ROS 2 topics;
- a ROS 2 Humble Docker container for MoveIt, ros2_control, YOLO, and the
  chatbot; and
- `SPARC.usd` as the scene.

Isaac Sim is the sole simulator and state source. MoveIt is the sole arm
motion owner. Do not run `main_launch.sh` alongside this guide because it
starts duplicate processes outside the Docker workflow.

## Get the repository

Clone the project into the current user's home directory:

```bash
cd "$HOME"
git clone https://github.com/runtimerobotics/nlp-pnp-robotic-arm.git
cd "$HOME/nlp-pnp-robotic-arm"
```

If the repository is already cloned, skip this section.

## Prerequisites

- Docker Engine with Docker Compose and NVIDIA Container Toolkit.
- An X11 desktop session for RViz and Isaac Sim.
- Isaac Sim 6.0.1 installed at
  `$HOME/Downloads/isaac-sim-standalone-6.0.1-linux-x86_64`.

Run the following once from a host terminal. It allows the current user to
open RViz from the Docker container:

```bash
cd "$HOME/nlp-pnp-robotic-arm"

export LOCAL_UID=$(id -u)
export LOCAL_GID=$(id -g)

xhost +si:localuser:$(id -un)
```

## 1. Build the Docker image and workspace

The default build includes the GPU YOLO dependencies and the
`topic_based_ros2_control` plugin used to bridge MoveIt commands and Isaac
joint states. Do not add a `--gpus` argument to `docker compose run`; the
Compose service already requests the GPU.

```bash
cd "$HOME/nlp-pnp-robotic-arm"

docker compose build
docker compose run --rm robot-dev bash docker/scripts/build-workspace.sh
```

## 2. Start Isaac Sim

In a new terminal, start Isaac with the Humble ROS 2 bridge on ROS domain 0.
The Isaac Sim path below is an example; replace it with the actual installation
path on your machine if yours is different.

```bash
cd "$HOME/nlp-pnp-robotic-arm"

env -u AMENT_PREFIX_PATH -u CMAKE_PREFIX_PATH -u COLCON_PREFIX_PATH \
  ROS_DOMAIN_ID=0 \
  RMW_IMPLEMENTATION=rmw_fastrtps_cpp \
  "$HOME/Downloads/isaac-sim-standalone-6.0.1-linux-x86_64/isaac-sim.sh" \
  --/isaac/startup/ros_bridge_extension=isaacsim.ros2.bridge \
  --/exts/isaacsim.ros2.bridge/ros_distro=humble
```

In Isaac Sim:

1. Open `$HOME/nlp-pnp-robotic-arm/SPARC.usd`.
2. Confirm that the ROS 2 Bridge extension is enabled.
3. Press **Play** and leave the simulation running.

When playing, the scene publishes `/isaac_joint_states` and `/rgb`, and
subscribes to `/isaac_joint_commands`.

## 3. Start MoveIt and RViz

In another terminal:

```bash
cd "$HOME/nlp-pnp-robotic-arm"

docker compose run --rm robot-dev bash -lc '
  source /opt/ros/humble/setup.bash
  source install/setup.bash
  ros2 launch ur5_moveit_config demo.launch.py
'
```

Wait until MoveIt and RViz are ready. The controller spawners must finish;
they must not remain in a `waiting for service
/controller_manager/list_controllers` loop.

## 4. Verify state, camera, and controllers

In a fourth terminal, confirm that Isaac is sending the inputs before planning
or executing motion:

```bash
cd "$HOME/nlp-pnp-robotic-arm"

docker compose run --rm robot-dev bash -lc '
  source /opt/ros/humble/setup.bash
  source install/setup.bash

  ros2 topic echo --once /isaac_joint_states
  ros2 topic info /rgb -v
  ros2 control list_controllers
'
```

Required results:

```text
/isaac_joint_states prints a sensor_msgs/msg/JointState message
/rgb has an Isaac Sim publisher
joint_state_broadcaster  active
arm_controller           active
gripper_controller       active
```

If `/isaac_joint_states` has zero publishers, Isaac is not running, is not in
Play mode, has its ROS 2 Bridge disabled, or is using a different
`ROS_DOMAIN_ID`.

## 5. Plan the safe starting pose

The configured `arm_home` pose is the all-zero, visually flat pose. In the
RViz Motion Planning panel:

1. Set **Planning Group** to `arm`.
2. Set **Goal State** to `arm_ready`.
3. Click **Plan** and inspect the complete path.
4. Click **Execute** only when the path is collision-free and the displayed
   start state matches the simulated robot.

Do not rotate the robot base in the USD stage to change the arm pose. The
scene and calibration expect the existing base transform.

## 6. Start perception and the chatbot

In a new terminal:

```bash
cd "$HOME/nlp-pnp-robotic-arm"

docker compose run --rm robot-dev bash docker/scripts/run-chatbot.sh
```

This one command starts:

- YOLOv8-OBB perception: `/rgb` to `/Yolov8_Inference`;
- target conversion: `/Yolov8_Inference` and `/target_class_cmd` to
  `/target_point`; and
- the FastAPI chatbot at <http://localhost:8000>.

Verify that a scene object is detected before asking for a pick:

```bash
cd "$HOME/nlp-pnp-robotic-arm"

docker compose run --rm robot-dev bash -lc '
  source /opt/ros/humble/setup.bash
  source install/setup.bash
  ros2 topic echo /Yolov8_Inference
'
```

## 7. Start the pick-and-place executor

Only after the checks above pass, start the node that consumes `/target_point`
and executes the pick/place trajectory:

```bash
cd "$HOME/nlp-pnp-robotic-arm"

docker compose run --rm robot-dev bash -lc '
  source /opt/ros/humble/setup.bash
  source install/setup.bash
  ros2 run ur5_moveit_config ur5_pick_place_cpp_r
'
```

Open <http://localhost:8000> and begin with a single detected item:

```text
pick red cube
```

When prompted, select a box:

```text
1
```

Other supported labels are `banana`, `marker`, `rubiks_cube`, `green_cube`,
`yellow_cube`, `measuring_tape`, `allen_key`, `chisel`, `knife`, and `clamp`.
Multiple labels may be requested in one command, for example:

```text
pick red cube and green cube
```

The chatbot's label-based pick commands do not require Ollama. Ollama is used
only for general conversational replies.

## Stop and clean up

Press `Ctrl-C` in the executor, chatbot, MoveIt, and Isaac terminals. When
finished with GUI containers, revoke the temporary X11 access from the host:

```bash
xhost -si:localuser:$(id -un)
```
