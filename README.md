# Samba docker image with NFS storage support

NFS is great, but lacks support for native extended attributes, which is required to run a samba server AND to have macOS clients.
This image emulates xattr using sidecar files, making use of a custom FUSE filesystem driver, which basically acts as an overlay filesystem.

The sidecar files are stored at the same location as the files they're associated to, and are hidden. For "image.png" this would result in a ".image.png.xattr" sidecar file.

## iOS 100093 error

This very descriptive error message (notoriously on iPad OS) indicates lack of extended attributes support. (actually it's something else but in this context)

## Usage

This image is based off https://github.com/dperson/samba and full credit goes to them for the samba part.

For the general usage, view their repositorie's readme.

=> To make the overlay system work, you need to have "fuse" installed on your docker host. After installing, make sure to either reboot or modprobe your host.
=> Use the docker-compose.yml file in THIS repository. In my example, I have mounted the home folder of the current user. The docker image will create an overlay over /mnt and expose the filesystem with xattr support at /shares.

## Credits

My starting point was here https://github.com/ServerContainers/samba but I had to switch to the dperson's image.
