# our skel/default/usr/lib/systemd/system/udev* or systemd-udev* definitions are both trying to start
# and that gives too much errors (non critical), but still very annoying
test -d $ROOTFS_DIR/usr/lib/systemd/system || return 0

# Fedora17: be aware these files are links!
# --------
# ls /usr/lib/systemd/system/sockets.target.wants/
#dbus.socket  systemd-initctl.socket  systemd-journald.socket  systemd-shutdownd.socket  udev-control.socket  udev-kernel.socket

# in our rear skel directory we have:
# ls sockets.target.wants/
#dbus.socket    systemd-journald.socket  systemd-shutdownd.socket      systemd-udevd-kernel.socket  udev-kernel.socket
#syslog.socket  systemd-logger.socket    systemd-udevd-control.socket  udev-control.socket

Log "Cleaning up systemd udev socket files"
my_udev_files=( $(find $ROOTFS_DIR/usr/lib/systemd/system/sockets.target.wants -type l -name "*udev*"  -printf "%P\n") )

for m in "${my_udev_files[@]}" ; do
    if [[ ! -h /lib/systemd/system/sockets.target.wants/$m ]] && [[ ! -h /usr/lib/systemd/system/sockets.target.wants/$m ]]; then
        rm -f $ROOTFS_DIR/usr/lib/systemd/system/sockets.target.wants/$m
    fi
done
