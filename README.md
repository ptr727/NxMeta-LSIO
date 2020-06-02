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
- The recently updated, and moved from GitLab to GitHub, [Network Optix Docker project](https://github.com/networkoptix/nx_open_integrations/tree/master/docker) states that `systemd` is no longer required, and this project was modified to remove the `systemd` modifications, making ongoing maintenance much simpler.
- The upcoming version 4.1 will include the ability to specify additional storage filesystems.
  - Access the server storage page, and verify that all mounted storage is listed, e.g. `http://localhost:7001/static/index.html#/info`.
  - If storage is not listed, attach to the container and run `cat /proc/mounts` to get a list of all the filesystem types, make a note of the filesystem types that are not showing up in storage, e.g. `grpcfuse /media fuse.grpcfuse rw,nosuid,nodev,relatime,user_id=0,group_id=0,allow_other,max_read=1048576 0 0` on Docker for Windows, use `fuse.grpcfuse`.
  - Access the `additionalLocalFsTypes` setting on the advanced server settings page, e.g. `http://localhost:7001/static/index.html#/advanced`.
  - Add `fuse.grpcfuse` for Docker for Windows and `fuse.shfs` for Unraid, and `zfs` for ZFS, e.g. `fuse.grpcfuse,fuse.shfs,zfs`.
  - Save the settings, restart the server, and verify that storage is now available.
- A few [observations](https://support.networkoptix.com/hc/en-us/community/posts/360044241693-NxMeta-4-1-Beta-on-Docker) on the "4.1.0.30731 R5" Beta:
  - Python was removed from the dependencies list, and `config_helper.py` was replaced with `config_helper.sh`.
  - The [calculation](http://mywiki.wooledge.org/BashFAQ/028) of `VMS_DIR=$(dirname $(dirname "${BASH_SOURCE[0]}"))` in `../bin/mediaserver` can result in bad paths when called from the same directory, e.g. `start-stop-daemon: unable to stat ./bin/./bin/mediaserver-bin (No such file or directory)`.
  - The filesystem filter logic incorrectly considers some volumes to be duplicates, turn on verbose logging : `2020-05-18 10:13:55.964    422 VERBOSE nx::vms::server::fs: shfs /archive fuse.shfs - duplicate`.
  - There is no apparent way to configure the `additionalLocalFsTypes` types at deployment time, it can only be done post deployment from the `http://localhost:7001/static/index.html#/advanced` web interface or via `http://admin:<passsword>@localhost:7001/api/systemSettings?additionalLocalFsTypes=fuse.grpcfuse,fuse.shfs`.
    - Some debugging shows the setting is stored in the `var/ecs.sqlite` DB file, in the `vms_kvpair` table, `name=additionalLocalFsTypes`, `value=fuse.grpcfuse,fuse.shfs,zfs`.
    - This DB table contains lots of other information, so it seems unfeasible to pre-seed the system with this DB file, and modifying it at runtime is as complex as calling the web service.
  - The mediaserver pollutes the filesystem by blindly creating a `Nx MetaVMS Media` folder and DB files in any storage it finds.
- It would be so much easier if admins were allowed to just explicitly specify storage locations...
