# add-ssh-to-image
Add the /boot/ssh file to Raspbian / Debian / Ubuntu disk image so ssh
will start automatically on first boot
--
Recent Debian based distros have taken the wise move of disabling ssh by
default, particularly when they have default credentials. Unfortunately,
for headless applications, ssh is necessary for even basic access to the
system so one can change those default credentials. Because of this, the
distributions provide a simple hook to just add a file named `ssh` in
the boot partition, and ssh will be enabled. Since boot is FAT formatted,
a bootable disk (such as USB or SD card) can be mounted on pretty much
any OS to read this file.

The limitation to this approach is that it is still a manual step. In the
modern world of infrastructure as code, this is a big potential failure
point, especially when one is building dozens of systems or rebuilding the
same system dozens of times. A better solution is to just update the disk
image once such that it's there every single time you write the image; no
additional work needed.

That's what this script does. It is designed to run on Debian-based
distros (given the use of apt to ensure everything is installed), but
should be easily adaptable for RPM-based distros. It does not work on
WSL, apparently due to a limitation in the access WSL has to the
loopback device. I doubt it works on OS X either; I lost faith in Apple
when they decided that BSD meant they didn't have to give back to the
community anymore (we saw how well that worked out for Sun, or IBM in
the AIX days), and gave up on them entirely when they decided that
working keyboards were unimportant.

All you need to do to run it is:
`./add-ssh-to-image.sh <path-to-image-file>`
You will need enough room in your current working directory for the
decompressed image file, permission to write a file in the directory
containing the original image file and enough room in the directory containing
the original image file for a new zip file containing the updated image
with the /boot/ssh file.

Note that if the original file is not a zip file, we assume it is
the image file itself, and it will be modified in place and moved
to a new filename denoting it is an ssh image.

Also note that the mount and umount operations must be done as root,
so this script must be run from an account that has sudo access and
you will be prompted for your password as appropriate. Fortunately,
it is a simple script and examining it to understand what it is doing
is encouraged.
