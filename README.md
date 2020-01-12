# Wake-and-Sync

## About

A simple script that turns on a second computer, backup data with rsync, and shutdown the second computer if no one is currently logged in. It is intended to be ran automatically with a cron job. At the beginning of every month, deleted files from source machine will be deleted on destination machine.

## Dependencies

This script was written for my Ubuntu Server and requires the `rsync` and `wakeonlan` packages. 

It should be possible to adpat this to other distributions be substituting the `wakeonlan` package for something equivalent on your distro.

## Configuration

In the script, these fields need to filled out:

- `wol` - enter the MAC address of the NIC of the destination machine. Make sure the interface supports wake on lan.

You can check if your interface has wake on lan support enabled by installing `ethtool` and running 
```
# ethtool interface | grep Wake-on
```

You should see a `g` next to "Wake-on" if enabled. You may have to use ethtool to enable wake on lan as well as making sure support is turned on in your machine's bios.

- `backupsrv` - IP address of destination machine
- `sourcedir` - source directory
- `username` - username of user on destination machine for backing up

## Options

- `-w` - Normal backup. Will rsync to destination machine without deleting files.
- `-m` - Monthly backup. Will delete files on destination machine that have been deleted on source machine and then rsync files.

## Disclaimer

This script was used between my Ubuntu servers which have been decommissioned, so I'm not using this anymore. I'm sharing this for anyone who has a primary and backup Ubuntu server/NAS where the backup is spent turned off most of the time. Since I no longer have the machines, I won't be able to test this anymore. 