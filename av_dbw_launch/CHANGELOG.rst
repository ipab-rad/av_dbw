^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Changelog for package av_dbw_launch
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

3.0.0 (2026-07-14)
------------------
* Port Dockerfile to Jazzy/Noble, clone & compile dbw from source (`#31 <https://github.com/ipab-rad/av_dbw/issues/31>`_)
* Contributors: Alejandro Bordallo Micó

2.0.0 (2026-03-11)
------------------

1.1.0 (2024-06-05)
------------------
* Add bash args to optionally load local cyclone_dds
* Contributors: Alejandro Bordallo, hect95

1.0.0 (2024-05-21)
------------------
* Add Cyclone DDS ROS RMW
  - Configure DDS for high msg throughput 
* Add docker build github workflow
* Add pre-commit support
* Add ROS 2 av_dbw_launch cfg to run dataspeed FORD dbw ROS driver
  - Dockefile based on ubuntu 22.04
  ROS 2 Humble
  - dev.sh and runtime.sh scrips are added
  - Docker container is synchronised with host time
* Contributors: Hector Cruz, hect95
