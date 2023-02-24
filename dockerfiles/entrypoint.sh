#!/bin/bash
set -e

# setup ros environment (same as ROS's official dockerfile)
# source "/opt/ros/$ROS_DISTRO/setup.bash"
echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> ~/.bashrc

# Musit use this to execute next command or container will exit
exec "$@"