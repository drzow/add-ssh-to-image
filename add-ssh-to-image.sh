#!/bin/bash

# Get the image file name
ORIG=$1
if [ -z "${ORIG}" ]; then
  echo "Usage: $0 <PathToImageFile>"
  exit 1
fi

# Install all the tools we need
sudo apt install -y unzip zip

# If the file is compressed, decompress it
case ${ORIG} in
*.zip )
  IMAGE=$(unzip ${ORIG} | grep img | awk '{print $2}')
  ISZIP="Y"
  ;;
# Otherwise, use the original
*.img )
  IMAGE=${ORIG}
  ISZIP="N"
  ;;
*)
  echo "Image file should either be a zip or img file (using those extensions)"
  exit 2
  ;;
esac

# Find the sector size
SECTORSIZE=$(fdisk -l ${IMAGE} | grep 'Sector size' | awk '{print $4}')

# Find the starting sector of the boot partition
STARTSECTOR=$(fdisk -l ${IMAGE} | grep 'FAT32' | awk '{print $2}')

# Calculate the starting byte of the boot partition
STARTBYTE=$(( ${SECTORSIZE} * ${STARTSECTOR} ))

# Create a mount point
mkdir -p mnt

# Mount the partition on the mount point
sudo mount -o loop,offset=${STARTBYTE} ${IMAGE} mnt

# Create the ssh file
sudo touch mnt/ssh

# Unmount the partition
sudo umount mnt

# Remove the mount point
rmdir mnt

# Determine the basename (with path) of the image file and original file
IMAGEBASE="${IMAGE%.*}"
echo "IMAGEBASE is ${IMAGEBASE}"
ORIGBASE="${ORIG%.*}"
echo "ORIGBASE is ${ORIGBASE}"

# Append "-ssh" to the filename
SSHIMGNAME="${IMAGEBASE}-ssh.img"
echo "SSHIMGNAME is ${SSHIMGNAME}"
mv ${IMAGE} ${SSHIMGNAME}
SSHORIGNAME="${ORIGBASE}-ssh"
echo "SSHORIGNAME is ${SSHORIGNAME}"

# Create a zip with the updated filename containing the updated image file
zip ${SSHORIGNAME} ${SSHIMGNAME}

# Remove the unzipped image file
if [ "${ISZIP}" = "Y" ]; then
  rm ${SSHIMGNAME}
fi

