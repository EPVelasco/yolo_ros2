FROM osrf/ros:humble-desktop

LABEL maintainer="edison.velasco@ua.es"

ENV DEBIAN_FRONTEND=noninteractive

# Requirements 
RUN apt update && apt upgrade -y && \
    apt install -y --no-install-recommends \
    curl wget gnupg2 lsb-release sudo nano vim gedit \
    python3 python3-pip python3-dev build-essential git cmake \
    v4l-utils
    
# Create ros2_ws and copy files
WORKDIR /root/yolo_ws/
SHELL ["/bin/bash", "-c"]
COPY ./yolo_ws/src/yolo_ros2 /root/yolo_ws/src/yolo_ros2

# Install dependencies
RUN apt-get update
RUN rosdep install --from-paths src --ignore-src -r -y

RUN if [ "$(lsb_release -rs)" = "24.04" ] || [ "$(lsb_release -rs)" = "24.10" ]; then \
    pip3 install -r src/yolo_ros2/requirements.txt --break-system-packages --ignore-installed; \
    else \
    pip3 install -r src/yolo_ros2/requirements.txt; \
    fi

# Build the ws with colcon
RUN source /opt/ros/${ROS_DISTRO}/setup.bash && colcon build
ENV ROS_DOMAIN_ID=42

# Setup bashrc
RUN echo "TERM=xterm-256color" >> ~/.bashrc && \
    echo "# COLOR Text" >> ~/.bashrc && \
    echo "PS1='\[\033[01;33m\]\u\[\033[01;33m\]@\[\033[01;33m\]\h\[\033[01;34m\]:\[\033[00m\]\[\033[01;34m\]\w\[\033[00m\]\$ '" >> ~/.bashrc && \
    echo "CLICOLOR=1" >> ~/.bashrc && \
    echo "LSCOLORS=GxFxCxDxBxegedabagaced" >> ~/.bashrc 
RUN echo "source /root/yolo_ws/install/setup.bash" >> ~/.bashrc


CMD ["bash"]