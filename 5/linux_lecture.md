## Chapter 4: Disks and Filesystems<a name="Chapter4"></a>
Partitions are subdivisions of the whole disk, on Linux, they’re denoted with a number after the whole block device.
The kernel presents each partition as a block device, just as it would an entire disk. Partitions are defined on a small
 area of the disk called a partition table.
The next layer after the partition is the filesystem, the database of files and directories that you’re accustomed 
to interacting with in user space.

### Partitioning disk devices
There are many kinds of partition tables. The traditional table is the one found inside the Master Boot Record (MBR).
A newer standard is the Globally Unique Identifier Partition Table (GPT). Some linux partition tools are:

    * parted: A text-based tool that supports both MBR and GPT
    * gparted: A graphical version of parted
    * fdisk: The traditional text-based Linux disk partitioning tool. fdisk does not support GPT
    * gdisk: A version of fdisk that supports GPT but not MBR

#### Viewing a Partition Table
You can view your system’s partition table with parted -l. An MBR partition can be of type primary, extended, and 
logical. A primary partition is a normal subdivision of the disk. The basic MBR has a limit of four primary partitions 
so if you want more than four, you designate one partition as an extended partition.

#### Changing Partition Tables
Changing the partition table makes it quite difficult to recover any data on partitions that you delete because it 
changes the initial point of reference for a filesystem, yo need to ensure that no partitions on your target disk are 
currently in use. Different tools can be used to create the partitions, like _parted_, _gparted_, _gdisk_ or _fdisk_.
_fdisk_ and _parted_ modify the partitions entirely in user space.

#### Disk and Partition Geometry
The disk consists of a spinning platter on a spindle, with a head attached to a moving arm that can sweep across the 
radius of the disk,  even though you can think of a hard disk as a block device with random access to any block, 
there are serious performance consequences if you aren’t careful about how you lay out data on the disk.

#### Solid-State Disks (SSDs)
In olid-state disks (SSDs), random access is not a problem because there’s no head to sweep across a platter, but 
some considerations like _partition alignment_ (data is read in blocks of fixed size, if data is laid in two blocks 
you need to do two reads even if the amount of data to read is less than the block size).

### Filesystems
A filesystem is a form of database; it supplies the structure to transform a simple block device into the sophisticated 
hierarchy of files and subdirectories that users can understand. Filesystems are also traditionally implemented in 
the kernel, but there are also file System in User Space (FUSE) and Virtual File Systems (VFS).

#### Filesystem Types
These are the most common types of filesystems for data storage. The type names as recognized by Linux are in 
parentheses next to the filesystem names:

    * The Fourth Extended filesystem (ext4): current iteration of a line of filesystems native to Linux
    * ISO 9660 (iso9660): is a CD-ROM standard (most CD-ROMs use some variety of the ISO 9660 standard)
    * FAT filesystems (msdos, vfat, umsdos): pertain to Microsoft systems. Most modern Windows filesystems use the 
    vfat filesystem in order to get full access from Linux
    * HFS+ (hfsplus): Apple standard used on most Macintosh systems
    
#### Creating a Filesystem
To create filesystems as with partitioning, you’ll do this in user space because a user-space process can directly 
access and manipulate a block device. The _mkfs_ utility can create many kinds of filesystems:

```bash
# creates an ext4 filesystem
mkfs -t ext4 /dev/sdf2 
```
_mkfs_ is only a frontend for a series of filesystem creation programs, mkfs.fs, where fs is a filesystem type. So 
when you run mkfs -t ext4, mkfs in turn runs mkfs.ext4 located at _/sbin/mkfs.\*_

#### Mounting a Filesystem
The process of attaching a filesystem is called mounting. When the system boots, the kernel reads some configuration
 data and mounts root (/) based on the configuration data.In order to mount a filesystem, you must know the following:
    
    * The filesystem's device (where the actual filesystem data resides)
    * The filesystem type
    * The mount point—that: the place in the current system’s directory hierarchy where the filesystem will be attached
    
Example:
```bash
# The format of the command is: mount -t type device mountpoint
mount -t ext4 /dev/sdf2 /home/extra
```

#### Filesystem UUID
Device names can change because they depend on the order in which the kernel finds the devices. To solve this 
problem, you can identify and mount filesystems by their Universally Unique Identifier (UUID), a software standard. 
To view a list of devices and the corresponding filesystems and UUIDs on your system, use the _blkid_ program. 
To mount a filesystem by its UUID, use `mount UUID=<uuid> <Mount point>`.

#### Disk Buffering, Caching, and Filesystems
Unix buffers writes to the disk, when you unmount a filesystem with umount, the kernel automatically synchronizes 
with the disk. You can force the kernel to write the changes in its buffer to the disk by running the _sync_ command.

#### Filesystem Mount Options
Some important options of the mount command:

    * -t: To specify the filesystem type
    * -r: To mount the filesystem in read-only mode
    * -n: To ensure that mount does not try to update the system runtime mount database (/etc/mtab)
    * -o: To activate a filesystem option (-o <option>). Some of these options:
        - exec, noexec: Enables or disables execution of programs on the filesystem
        - suid, nosuid: Enables or disables setuid programs
        - ro Mounts the filesystem in read-only mode (as does the -r short option)
        - rw Mounts the filesystem in read-write mode
        - conv=rule (FAT-based filesystems) Converts the newline characters in files based on rule, which can be 
        binary, text, or auto.

#### Remounting a Filesystem
To reattach a currently mounted filesystem at the same mount point with different mount options do 
`mount <options> -o remount <mounting point>`

#### The /etc/fstab Filesystem Table
Linux systems keep a permanent list of filesystems and options in _/etc/fstab_. Each line describes a filesystem with 
the following fields:

    * The device or UUID
    * The mount point Indicates where to attach the filesystem
    * The filesystem type
    * Options Use long options separated by commas
    * Backup information for use by the dump command 
    * The filesystem integrity test order

#### Alternatives to /etc/fstab
Alternatives to the _/etc/fstab_ file are _/etc/fstab.d_ directory that contains individual filesystem configuration 
files and to configure _systemd_ units for the filesystems.

#### Filesystem Capacity
To view the size and utilization of your currently mounted filesystems, use the _df_ command. The output contains:

    * Filesystem: The filesystem device
    * 1024-blocks: The total capacity of the filesystem in blocks of 1024 bytes
    * Used: The number of occupied blocks
    * Available: The number of free blocks
    * Capacity: The percentage of blocks in use
    * Mounted on: The mount point
    
If your disk fills up and you need to know where the space is allocated, use the _du_ command. 

#### Checking and Repairing Filesystems
If errors exist in a mounted filesystem, data loss and system crashes may result. The tool to check a filesystem is 
_fsck_ there are different version of fsck for each filesystem type that Linux supports). To run fsck in interactive
 manual mode (-n for automatic mode), give the device or the mount point (as listed in /etc/fstab) as the argument:

```bash
fsck /dev/sdb1
```

##### Checking ext3 and ext4 Filesystems
You may wish to mount a broken ext3 or ext4 filesystem in ext2 mode because the kernel will not mount an ext3 or ext4
 filesystem with a nonempty journal. To flush the journal in an ext3 or ext4 filesystem to the regular filesystem 
 database, run e2fsck as follows `e2fsck –fy /dev/disk_device`
 
##### The worst case
The debugfs tool allows you to look through the files on a filesystem and copy them elsewhere.

#### Special-Purpose Filesystems
Most versions of Unix have filesystems that serve as system interfaces. That is, rather than serving only as a means 
to store data on a device, a filesystem can represent system information such as process IDs and kernel diagnostics. 
The special filesystem types in common use on Linux include the following:

    * proc: Mounted on /proc. Each numbered directory inside /proc is the process ID of a current process on the system. 
    The file /proc/self represents the current process
    * sysfs: Mounted on /sys
    * tmpfs Mounted on /run and other locations. tmpfs allows to use your physical memory and swap space as temporary 
    storage
    
### Swap Space
If you run out of real memory, the Linux virtual memory system can automatically move pieces of memory to and from a
 disk storage (swapping). The disk area used to store memory pages is called swap space (to view the current swap 
 memory use the _free_ command).
 
#### Using a Disk Partition as Swap Space
To use an entire disk partition as swap, make sure the partition is empty and run `mkswap dev`, where `dev` is the 
partition’s device. Last, execute `swapon dev` to register the space with the kernel.

#### Using a File as Swap Space
Use these commands to create an empty file, initialize it as swap, and add it to the swap pool:

```bash
dd if=/dev/zero of=<the swap file> bs=1024k count=<desired size in mb> 
mkswap <the swap file>
swapon <the swap file>
```

#### How Much Swap Do You Need?
Unix conventional wisdom said you should always reserve at least twice as much swap as you have real memory.

#### Inside a Traditional Filesystem
A traditional Unix filesystem has two primary components: a pool of data blocks where you can store data and a 
database system that manages the data pool. The database is centered around the _inode_ data structure. An _inode_ is a 
set of data that describes a particular file, including its type, permissions and where in the data pool the file data 
resides. _inodes_ are identified by numbers listed in an _inode_ table.

#### Viewing Inode Details
To view the _inode_ numbers for any directory, use the `ls -i` command. For more detailed _inode_ information, use the 
_stat_ command.