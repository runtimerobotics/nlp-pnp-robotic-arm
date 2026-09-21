# SPARC 🤖  
[![ROS2 Humble](https://img.shields.io/badge/ROS2-Humble-blue)](https://docs.ros.org/en/humble/)
[![Python 3.10](https://img.shields.io/badge/Python-3.10-green)](https://www.python.org/downloads/release/python-3100/)
[![MoveIt](https://img.shields.io/badge/MoveIt-Enabled-orange)](https://moveit.ros.org/)
[![YOLOv8](https://img.shields.io/badge/YOLOv8-OBB-red)](https://docs.ultralytics.com/)

**Smart Pick-n-Place with AI Robotics and Chatbot**  

![SPARC Demo](docs/PickPlace.gif)  

---

## 🌟 Overview  
SPARC is an intelligent **pick-and-place robotic system** built on **ROS2 Humble**, **Isaac Sim**, and **MoveIt**. It integrates:  
- **YOLOv8-OBB object detection** for real-time perception  
- **Franka Emika Panda / UR5 robot arms** for precise manipulation  
- **Chatbot interface** powered by **Ollama LLMs** for natural language control  

This allows users to **command the robot in plain English**, enabling smart and interactive task execution in simulation.  

---

## 🚀 Features  
- 🔍 Real-time object detection (YOLOv8 Oriented Bounding Boxes)  
- 🦾 Robotic arm control using MoveIt + ROS2  
- 🧠 Natural language chatbot interface (Ollama)  
- 🖼️ Camera calibration from Isaac Sim (fx, fy, cx, cy extraction)  
- 🛠️ Compatible with both **Franka Panda** and **UR5** arms  
- 🎯 Target point publishing for perception → planning integration  

---
## 📦 Dependencies  
- **ROS2 Humble**  
- **MoveIt** (`ros-humble-moveit-py`, `moveit` package)  
- **UR5 MoveIt config**  
- **Ultralytics (YOLOv8)**  
- **ROS2 Control + Controllers**  
  - `ros-humble-ros2-control`  
  - `ros-humble-ros2-controllers`  
  - `ros-humble-topic-based-ros2-control` (the Isaac Sim topic bridge used by
    `ros2_control`)
  - `ros-humble-gripper-controllers`  
- **Ollama** (for chatbot LLMs)  
- **Conda environments** 

---

## 🐳 Docker development environment

Docker provides a ROS 2 Humble environment for MoveIt, ros2_control, YOLO
perception, and the chatbot, while Isaac Sim runs on the host. For
prerequisites, build instructions, startup commands, verification, and
troubleshooting, see the
[Docker + Isaac Sim demo runbook](docs/docker-isaac-demo.md).

---

## 🤖 Running the Demo  

1. Clone the directory and navigate into the project folder:
```bash
   git clone https://github.com/sahilrajpurkar03/nlp-pnp-robotic-arm.git
   cd ~/nlp-pnp-robotic-arm
   source /opt/ros/humble/setup.bash
   colcon build && source install/setup.bash
```

3. Create a new conda environment named **ros2_humble_py310** with Python 3.10 

2. Install dependencies from `requirements.txt` inside the environment, as it is required for the Chatbot:  
```bash
   pip install -r requirements.txt
```
4. Open Isaac Sim.

5. Load the simulation file: `SPARC.usd`

6. Play the simulation

7. Launch the script to open RVIZ, MoveIt, and the control script for the robot:
```bash
   chmod +x main_launch.sh
   ./main_launch.sh
```
> **Note:** Bring the Robot to the `arm_ready` pose through the RVIZ GUI

8. To open the Chatbot (in new Terminal window)
```bash
   cd ~/Team7_SPARC
   conda activate ros2_humble_py310
   ./pick_place_chatbot_ui/launch.sh
```

9. Start typing commands in the chatbot and see the magic ✨🤖🚀

SPARC will handle the rest automatically 🚀  

---

## 🛠️ Debugging  

## RVIZ + MoveIt Launch
```bash
cd ~/nlp-pnp-robotic-arm
source /opt/ros/humble/setup.bash
colcon build
source install/setup.bash  
ros2 launch ur5_moveit_config demo.launch.py 
```

### UR5 Arm Demo  
```bash
cd ~/nlp-pnp-robotic-arm
source /opt/ros/humble/setup.bash
colcon build
source install/setup.bash
ros2 launch ur5_moveit_config demo.launch.py
ros2 run ur5_moveit_config ur5_pick_place_cpp_r
```

### Object Detection (YOLOv8-OBB)  
```bash
ros2 run yolov8obb_object_detection yolov8_obb_publisher
ros2 run yolov8obb_object_detection yolov8_obb_subscriber
```

### Chatbot Control  
```bash
cd ~/nlp-pnp-robotic-arm
conda activate ros2_humble_py310
source /opt/ros/humble/setup.bash
source install/setup.bash
./pick_place_chatbot_ui/launch.sh
```

### Check Published Target Points  
```bash
source /opt/ros/humble/setup.bash
ros2 topic echo /target_point
```

## 🎯 Competition Relevance  
SPARC demonstrates **seamless integration of AI and Robotics**, showcasing how natural language can be used to **control intelligent robotic arms** for pick-and-place tasks. This bridges perception, planning, and interaction—making robots more **intuitive, adaptable, and human-friendly**.  

---
