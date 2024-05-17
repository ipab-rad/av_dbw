FROM ros:humble-ros-base-jammy AS base

# Install basic dev tools (And clean apt cache afterwards)
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
        apt-get -y --quiet --no-install-recommends install \
        # Download tool
        curl \
        # Install Cyclone DDS ROS RMW
        ros-"$ROS_DISTRO"-rmw-cyclonedds-cpp \
    && rm -rf /var/lib/apt/lists/*

# Setup Dataspeed apt
RUN curl -sSL https://bitbucket.org/DataspeedInc/ros_binaries/raw/master/dataspeed.key -o /usr/share/keyrings/dataspeed-archive-keyring.gpg \
    && sh -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/dataspeed-archive-keyring.gpg] http://packages.dataspeedinc.com/ros2/ubuntu \
    $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2-dataspeed-public.list > /dev/null'

# Setup Dataspeed rosdep
RUN sh -c "echo \"yaml http://packages.dataspeedinc.com/ros2/ros-public-\$ROS_DISTRO.yaml \$ROS_DISTRO\" \
    > /etc/ros/rosdep/sources.list.d/30-dataspeed-public-\$ROS_DISTRO.list"


# Install basic dev tools (And clean apt cache afterwards)
RUN apt-get update \
    && rosdep update \
    && DEBIAN_FRONTEND=noninteractive \
        apt-get -y --quiet --no-install-recommends install \
        # Dataspeed Ford Drive-By-Wire
        ros-"$ROS_DISTRO"-dbw-ford \
        # Dataspeed Power Distribution System
        # ros-noetic-dataspeed-pds-can \
    && rm -rf /var/lib/apt/lists/*

# Setup ROS workspace folder
ENV ROS_WS /opt/ros_ws
WORKDIR $ROS_WS

# Set cyclone DDS ROS RMW
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

COPY ./cyclone_dds.xml $ROS_WS/

# Configure Cyclone cfg file
ENV CYCLONEDDS_URI=file://${ROS_WS}/cyclone_dds.xml

# Enable ROS log colorised output
ENV RCUTILS_COLORIZED_OUTPUT=1

# -----------------------------------------------------------------------

FROM base AS prebuilt

# Import Five DBW code into docker image
COPY av_dbw_launch $ROS_WS/src/

# Source ROS setup for dependencies and build our code
RUN . /opt/ros/"$ROS_DISTRO"/setup.sh \
    && colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release

# -----------------------------------------------------------------------

FROM base AS dev

# Install basic dev tools (And clean apt cache afterwards)
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
        apt-get -y --quiet --no-install-recommends install \
        # Dbw joystick controller
        ros-"$ROS_DISTRO"-dbw-ford-joystick-demo \
        # Command-line editor
        nano \
        # Ping network tools
        inetutils-ping \
        # Bash auto-completion for convenience
        bash-completion \
    && rm -rf /var/lib/apt/lists/*

# Add sourcing local workspace command to bashrc when running interactively
# Add colcon build alias for convenience
RUN echo "source /opt/ros/$ROS_DISTRO/setup.bash" >> /root/.bashrc && \
    echo 'alias colcon_build="colcon build --symlink-install \
            --cmake-args -DCMAKE_BUILD_TYPE=Release && \
            source install/setup.bash"' >> /root/.bashrc

# Enter bash for development
CMD ["bash"]

# -----------------------------------------------------------------------

FROM base AS runtime

# Copy artifacts/binaries from prebuilt
COPY --from=prebuilt $ROS_WS/install $ROS_WS/install

# Add command to docker entrypoint to source newly compiled code in container
RUN sed --in-place --expression \
      "\$isource \"$ROS_WS/install/setup.bash\" " \
      /ros_entrypoint.sh

# Launch Five DBW launchfile
CMD ["ros2", "launch", "av_dbw_launch", "av_dbw.launch.xml"]
