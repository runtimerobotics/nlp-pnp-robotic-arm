# syntax=docker/dockerfile:1
# ROS 2 Humble is the project target and is based on Ubuntu 22.04 (Jammy).
FROM ros:humble-ros-base-jammy

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG INSTALL_ML_DEPS=0
ENV DEBIAN_FRONTEND=noninteractive \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1

# MoveIt and the ament lint tools are installed in the image so a fresh bind
# mount can build and test this workspace. Isaac Sim is intentionally not
# included: it is distributed and licensed separately and should run on the
# host (or in its own NVIDIA Isaac Sim container).
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    python3-colcon-common-extensions \
    python3-pip \
    python3-pytest \
    python3-rosdep \
    python3-vcstool \
    ros-humble-ament-copyright \
    ros-humble-ament-flake8 \
    ros-humble-ament-pep257 \
    ros-humble-cv-bridge \
    ros-humble-gripper-controllers \
    ros-humble-moveit \
    ros-humble-ros2-controllers \
    ros-humble-ros2-control \
    ros-humble-topic-based-ros2-control \
    ros-humble-xacro \
 && rm -rf /var/lib/apt/lists/*

COPY docker/requirements-ml.txt /tmp/requirements-ml.txt
RUN python3 -m pip install --no-cache-dir --upgrade pip \
 && if [[ "${INSTALL_ML_DEPS}" == "1" ]]; then \
      python3 -m pip install --no-cache-dir -r /tmp/requirements-ml.txt; \
    fi \
 && python3 -m pip install --no-cache-dir 'fastapi>=0.100' 'uvicorn>=0.20' 'numpy<2' \
 && python3 -m pip install --no-cache-dir 'pytest>=8,<9'

COPY docker/entrypoint.sh /usr/local/bin/sparc-entrypoint
RUN chmod +x /usr/local/bin/sparc-entrypoint \
 && mkdir -p /workspaces/nlp-pnp-robotic-arm /tmp/sparc-home /tmp/sparc-ros \
 && chmod 1777 /tmp/sparc-home /tmp/sparc-ros

WORKDIR /workspaces/nlp-pnp-robotic-arm
ENTRYPOINT ["/usr/local/bin/sparc-entrypoint"]
CMD ["bash"]
