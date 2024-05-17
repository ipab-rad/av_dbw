# av_dbw
Drive-by-wire interface between ROS 2 and usb-CANbus Dataspeed tool for a FORD Mondeo

## Usage

This repository is designed to be used alongside a Docker container. Quickly build and run the Docker container using `runtime.sh` for runtime or debugging, and `dev.sh` for a convenient development setup.

### Runtime or Debugging

Execute the drive-by-wire ROS nodes in runtime mode or start an interactive bash session for detailed debugging:

```bash
./runtime.sh [bash]
```

- **Without arguments**: Activates the container in runtime mode.
- **With `bash`**: Opens an interactive bash session for debugging.

### Development

Prepare a development setting that reflects local code modifications and simplifies the build process:

```bash
./dev.sh
```

- **Live Code Synchronization**: Mounts local `av_dbw_launch` directory with the container.