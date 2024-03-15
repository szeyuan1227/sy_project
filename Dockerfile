FROM osrf/ros:humble-desktop-full

ENV DEBIAN_FRONTEND=noninteractive

ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN apt-get update && apt-get install -y \
 wget \
 git \
 bash-completion \
 build-essential \
 sudo \
 && rm -rf /var/lib/apt/lists/*
# Now create the same user as the host itself
ARG UID=1000
ARG GID=1000
RUN addgroup --gid ${GID} ros
RUN adduser --gecos "ROS User" --disabled-password --uid ${UID} --gid ${GID} ros
RUN usermod -a -G dialout ros
ADD config/99_aptget /etc/sudoers.d/99_aptget
RUN chmod 0440 /etc/sudoers.d/99_aptget && chown root:root /etc/sudoers.d/99_aptget

ENV USER ros
USER ros 
ENV HOME /home/${USER} 
RUN mkdir -p ${HOME}/ros_ws/src

WORKDIR ${HOME}/ros_ws/
RUN /bin/bash -c "source /opt/ros/humble/setup.bash; colcon build --symlink-install"

# set up environment
COPY config/update_bashrc /sbin/update_bashrc
RUN sudo chmod +x /sbin/update_bashrc ; sudo chown ros /sbin/update_bashrc ; sync ; /bin/bash -c /sbin/update_bashrc ; sudo rm /sbin/update_bashrc
# Change entrypoint to source ~/.bashrc and start in ~
COPY config/entrypoint.sh /ros_entrypoint.sh
RUN sudo chmod +x /ros_entrypoint.sh ; sudo chown ros /ros_entrypoint.sh ;

RUN sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/* 
ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]