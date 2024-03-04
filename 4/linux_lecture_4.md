## Chapter 4: Пристрої в Linux
### Device Files
Most devices on a Unix system because the kernel presents many of the device I/O interfaces to user processes as files.

Some devices are also accessible to standard programs like `cat`, although not all devices or device capabilities are accessible with standard file I/O. If you list the contents of _/dev_, the first letter displayed would tell you the type of device:

- Block device (b): Programs access data from a block device in fixed chunks (like disc devices)
- Character device (c): Works with data streams. You can only read/write characters from/to character devices. 

Character devices don’t have a size; when you read from or write to one, the kernel usually performs a read or write operation on the device (like printers). During character device interaction, the kernel cannot back up and reexamine the data stream after it has passed data to a device or process
- Pipe devices (p): like character devices, with another process at the other end of the I/O stream instead of a kernel driver
- Socket device (s): special-purpose interfaces that are frequently used for interprocess communication
    
### The sysfs Device Path
The kernel assigns devices in the order in which they are found, so a device may have a different name between reboots.

The Linux kernel offers the sysfs interface through a system of files and directories to provide a uniform view for attached devices based on their actual hardware attributes. The base path for devices is _/sys/devices_.

There are a few shortcuts in the _/sys_ directory. _/sys/block_ should contain all of the block devices available on a system. To find the sysfs location of a device in _/dev_ use the `udevadm` command:

`udevadm info --query=all --name=/dev/sda`

### dd and Devices
The program dd is extremely useful when working with block and character devices, its function is to read from an input file or stream and write to an output file or stream (dd copies data in blocks of a fixed size).

Usage: 
`dd if=/dev/zero of=new_file bs=1024 count=1`

### device name summary
It can sometimes be difficult to find the name of a device. Some common Linux devices and their naming conventions are:

#### Hard Disks: /dev/sd*
These devices represent entire disks; the kernel makes separate device files, such as _/dev/sda1_ and _/dev/sda2_, for the partitions on a disk.

The sd portion of the name stands for SCSI disk (Small Computer System Interface). To list the SCSI devices on your system, use a utility that walks the device paths provided by sysfs.

![SCSI devices](images/Figure3-1.png)

Most modern Linux systems use the Universally Unique Identifier (UUID) for persistent disk device access.

#### CD and DVD Drives: /dev/sr*
The /dev/sr* devices are read only, and they are used only for reading from discs.

#### PATA Hard Disks: /dev/hd*
The Linux block devices /dev/hd* are common on older versions of the Linux kernel and with older hardware.

#### Terminals: /dev/tty*, /dev/pts/*, and /dev/tty
Terminals are devices for moving characters between a user process and an I/O device, usually for text output to a terminal screen. Pseudoterminal devices are emulated terminals that understand the I/O features of real terminals. 

Two common terminal devices are _/dev/tty1_ (the first virtual console) and _/dev/pts/0_ (the first pseudoterminal device).

The /dev/tty device is the controlling terminal of the current process. If a program is currently reading and writing to a terminal, this device is a synonym for that terminal. A process does not need to be attached to a terminal.

Linux has two primary display modes: text mode and an X Window System server (graphics mode). You can switch between the different virtual environments with the ctrl-alt-Function keys.

#### Parallel Ports: /dev/lp0 and /dev/lp1
Representing an interface type that has largely been replaced by USB.

You can send files (such as a file to be printed) directly to a parallel port with the cat command.

#### Audio Devices: /dev/snd/*, /dev/dsp, /dev/audio, and More
Linux has two sets of audio devices. There are separate devices for the Advanced Linux Sound Architecture (ALSA in _/dev/snd_) system interface and the older Open Sound System (OSS).

#### Creating Device Files
The mknod command creates one device (deprecated). You must know the device name as well as its major and minor numbers. 

### udev
The Linux kernel can send notifications to a user-space process (named udevd) upon detecting a new device on the system.

The user-space process on the other end examines the new device’s characteristics, creates a device file, and then performs any device initialization.

#### devtmpfs
The devtmpfs filesystem was developed in response to the problem of device availability during boot. This filesystem is similar to the older devfs support, but it’s simplified.

The kernel creates device files as necessary, but it also notifies udevd that a new device is available.
 
#### udevd Operation and Configuration
The udevd daemon operates as follows:

    1. The kernel sends udevd a notification event, called a uevent, through an internal network link
    2. udevd loads all of the attributes in the uevent
    3. udevd parses its rules, and it takes actions or sets more attributes based on those rules

#### udevadm
The udevadm program is an administration tool for udevd.

You can reload udevd rules and trigger events, but perhaps the most powerful features of udevadm are the ability to search for and explore system devices and the ability to monitor uevents as udevd receives them from the kernel.

#### Monitoring Devices
To monitor uevents with udevadm, use the monitor command: `udevadm monitor`

### in-depth: scsi and the linux kernel
The traditional SCSI hardware setup is a host adapter linked with a chain of devices over an SCSI bus. This adapter is attached to a computer, the host adapter and devices each have an SCSI ID and there can be 8 or 16 IDs per bus, depending on the SCSI version.

The host adapter communicates with the devices through the SCSI command set in a peer-to-peer relationship; the devices send responses back to the host adapter. 

The SCSI subsystem and its three layers of drivers can be described as:
    
- The top layer handles operations for a class of device
- The middle layer moderates and routes the SCSI messages between the top and bottom layers, and keeps track of all of the SCSI buses and devices attached to the system
- The bottom layer handles hardware-specific actions. The drivers here send outgoing SCSI protocol messages to specific host adapters or hardware, and they extract incoming messages from the hardware

#### USB Storage and SCSI
USB is quite similar to SCSI—it has device classes, buses, and host controllers.

The Linux kernel includes a three-layer USB subsystem that closely resembles the SCSI subsystem, with device-class drivers at the top, a bus management core in the middle, and host controller drivers at the bottom.

#### SCSI and ATA
To connect the SATA-specific drivers of the kernel to the SCSI subsystem, the kernel employs a bridge driver, as with the USB drives.

The optical drive speaks ATAPI, a version of SCSI commands encoded in the ATA protocol. 
 