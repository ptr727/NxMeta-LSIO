# NxMeta IPVMS Docker

This is a docker project for the [NxWitness NxMeta IPVMS](https://meta.nxvms.com/).  
[NxMeta](https://meta.nxvms.com/content/about) is the developer portal for the [NetworkOptix Nx Witness VMS](https://www.networkoptix.com/nx-witness/).  

This project is based on the [DWSpectrum-LSIO project](https://github.com/ptr727/DWSpectrum-LSIO).  
This project is used to test early access or Beta builds of Nx Witness.

## License

![GitHub](https://img.shields.io/github/license/ptr727/NxMeta-LSIO)  

## Build Status

![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/ptr727/nxmeta-lsio?logo=docker)  
Pull from [Docker Hub](https://hub.docker.com/r/ptr727/nxmeta-lsio)  
Code at [GitHub](https://github.com/ptr727/NxMeta-LSIO)

## Usage

Refer to the [DWSpectrum-LSIO project](https://github.com/ptr727/DWSpectrum-LSIO) for details.

## Notes

- Sign up for early access releases at the [developer portal](https://support.networkoptix.com/hc/en-us/articles/360046713714-Get-an-Nx-Meta-Build)
- Beta releases are listed in the [patches download](https://meta.nxvms.com/downloads/patches) section.
- The upcoming version 4.1 will include the ability to specify additional storage filesystems.
  - Due to the mediaserver filesystem type filtering it is not currently possible to use native storage on Unraid and Docker for Windows storage.
  - Access the info page and storage tab, and verify that all mounted storage is listed. E.g. `http://localhost:7001/static/index.html#/info`.
  - If storage is not listed, attach to the container and run `cat /proc/mounts` to get a list of all the filesystem types, make a note of the filesystem types that are not showing up in storage. E.g. `grpcfuse /media fuse.grpcfuse rw,nosuid,nodev,relatime,user_id=0,group_id=0,allow_other,max_read=1048576 0 0` on Docker for Windows, use `fuse.grpcfuse`.
  - Access the `additionalLocalFsTypes` setting on the advanced server settings page. E.g. `http://localhost:7001/static/index.html#/advanced`.
  - Add `fuse.grpcfuse` for Docker for Windows and `fuse.shfs` for Unraid, e.g. `fuse.grpcfuse, fuse.shfs`.
  - Save the settings, reboot, and verify that storage is now available.
  - TODO: Figure out where the settings are stored, so that we can inject the settings during container creation, it does not appear to be in `etc/mediaserver.conf`?
- A few notes on 4.0 vs. 4.1 installer changes:
  - Python was removed from the dependencies list, and `config_helper.py` was replaced with `config_helper.sh`.
  - Still not fixed: The calculation of `VMS_DIR=$(dirname $(dirname "${BASH_SOURCE[0]}"))` in `../bin/mediaserver` results in bad paths e.g. `start-stop-daemon: unable to stat ./bin/./bin/mediaserver-bin (No such file or directory)`.
  - Still not fixed: The DEB installer does not reference all used dependencies. When trying to minimizing the size of the install by using `--no-install-recommends` we get a `OCI runtime create failed` error. We have to manually add the following required dependencies: `gdb gdbserver binutils lsb-release`.
