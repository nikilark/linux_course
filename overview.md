# How Linux Works

## Overview

### Kernel

- kernel
  - is _in memory_, telling CPU where to look for its next task
  - runs in **kernel mode**
- **kernel space** - the memory area only accessible by kernel
- **user space** - part of the main memory accessible by user processes
- kernel can run **kernel threads**
  - like processes but have access to kernel space
  - `kthreadd`
  - `kblockd`
- Kernel manages:
  - processes
    - which processes are allowed to use the CPU?
  - memory
  - device drivers
  - system calls and support
    - processes _normally_ use system calls to communicate with kernel

#### Process Management

- processes run _simultaneously_
  - however they do not run at _exactly_ the same time
  - each process uses the CPU for a **time slice**
  - **context switch** - kernel's responsibility
    - _when_ does the kernel run?
    - kernel runs _between_ process time slices during a **context switch**

#### Memory Management

- kernel manages memory during **context switch**
- modern CPUs include a **Memory Management Unit (MMU)**
  - enabling **virtual memory**
  - **page table**

#### System Calls and Support

- `fork()`
  - kernel creates a _nearly identical_ copy of the process
- `exec(program)`
  - kernel loads & starts `program`, replacing the current process
- other than init, _all_ new user processes start as a result of `fork()`
  - _then_, probably runs `exec()` to start a new program
- **pseudodevices**
  - look-alike devices to user processes
  - but implemented purely in software
  - e.g. `/dev/random` - the kernel random number generator device

### User Space

- memory for the entire collection of running processes
- **userland**

### Users

- every user-space process has a user **owner**

## Basic Commands and Directory Hierarchy

### Commands

- `/bin/sh` - the Bourne Shell
- `bash` - the **Bourne Again Shell**
- `Ctrl-D` vs. `Ctrl-C`
  - `Ctrl-D` stops the current standard input entry from terminal with an `EOF` message
  - `Ctrl-C` terminates program regardless of its input/output
- `rmdir` - removes a `dir`
  - fails when `dir` is _NOT_ empty
- **Globbing**
  - to match _all_ files: `*`
  - `?` - match exactly one character
  - `'*'` - if you do not want the shell to expand a glob
  - Shell performs expansions _before_ running commands, and only then
- `grep`
  - `grep root /etc/passwd` - print lines in `/etc/passwd` that contain `root`
  - handy when operating on multiple files - it prints filename in addition to the matching line
  - Options:
    - `-i` - case insensitive
    - `-v` - inverse search
    - `-e` & `-E` pattern
      - `.*` - any number of characters, including none
      - `.+` - 1 or more
      - `.` - exactly one
- `less`
  - one screenful at a time
  - search for text inside `less`
    - `/word` - search forward
    - `?word` - search backward
- `pwd`
  - `-P` - avoid all symlinks
- `diff` - difference between two text files
  - `diff -u`
- `file` - format of a file
- `find`
  - `$ find dir -name file -print`
    - find `file` in `dir`
    - `-name` - pattern, which should _NOT_ include a slash `/`
    - `-print` - print full file name on stdin, followed by newline
    - `-print0` - print followed by null (instead of newline)
- `locate` - similar to `find` but searches against a pre-built index
  - _not_ real time
- `tail` & `head`
- `sort` - put lines of a text file in alphanumeric order
- `chsh` - change your shell

### Environment and Shell Variables

- _ALL_ processes on Unix systems have environment variable storage
- OS passes _all_ shell's env variables to programs run by shell

### Command Path

- separated by `:`

### Manual

- Manual page followed by **section number**
- `man <section_number> passwd`
- `info <command>`

### Shell I/O

- pipe `|`
- stderr to stdout - `2>&1`

### Processes

- `ps`
  - `TTY` - the terminal device where the process is running
  - `ps x` - show all _your_ running processes
  - `ps ax` - show _ALL_ processes _on the system_
- `$$` - current shell's PID

#### Process Termination

- `kill` - sends `TERM`
- `kill -STOP <PID>` - freeze (instead of terminating)
  - process still in memory
- `kill -CONT <PID>` - run the stopped process _again_
- `Ctrl-C` sends an `INT` signal
- `kill -KILL`
  - send the `KILL` signal
  - `kill -9`

#### Job Control

- `TSTP` & `CONT` signals
- If a program tries to read from stdin while it's in the background, it can freeze/terminate
  - try to `fg` to bring it back

### File Modes and Permissions

#### Permissions

- `s` permission (instead of `x`): the executable is **setuid**
  - when the program is executed, it runs as though the file owner is the user instead of you
  - run as root in order to get the privileges needed to change system files
  - e.g. `paswd` - needs to change `/etc/passwd`
- To change,
  - `chmod <group/user>+<permission> file`
  - `chmod <group/user>-<permission> file`
- You can _only_ access a file in a directory _if_ the directory is executable
- `umask` - applies a predefined set of permissions to any new file created by you
  - `<mask>` - permission bits that should _NOT_ be set on a newly created file
  - **logical complement**!!!
  - sets to `<mask> & 0777`
  - Use `umask 022` if you want everyone to be able to see all files & directories
  - Use `umask 077` if you do _NOT_ want anyone to be able to see all files & directories

#### Symbolic Links

- `<file_pointed_to>` does _NOT_ have to mean anything
  - does _NOT_ need to exist
- from `target` to `linkname`
  - `ln -s target linkname`
  - `target` - file/directory `linkname` points to

### Archiving and Compressing Files

- `gzip` and `tar`

#### `gzip`

- _ONLY_ compress, does _NOT_ archive
  - i.e. does _NOT_ pack multiple files/directories into a single one
- to compress, `gzip <file>`
- to unzip, `gunzip <file.gz>`

#### `tar`

- to create an archive - `tar cvf <archive>.tar file1 file2 ...`
- Flags
  - `c` - create mode
  - `v` - verbose
  - `f` - file option
    - followed by the file name to create
    - to use stdin/stdout, set filename to `-`
  - `x` - extract mode
- To unpack `.tar` file, `tar xvf <archive>.tar`
  - does _NOT_ remove the archived `.tar` file after extraction
- **Table-of-Contents Mode**
  - using flag `t` instead of `x`
  - check the contents of a `.tar` file _before_ unpacking
- Consider using `-p` when _unpacking_
  - preserves permissions
  - default under superuser

#### `.tar.gz` - Compressed Archives

- `gunzip` first
- then `tar xvf`

#### `zcat`

- Combine archival and compression functions with a pipeline
- `zcat file.tar.gz | tar xvf -`
- `zcat` - `gunzip -dc`
  - `-d` - decompress
  - `-c` - send result to standard output
- `tar` has a shortcut for `zcat`
  - `tar ztvf file.tar.gz`
- `.tgz` file === `.tar.gz` file

### Linux Directory Hierarchy

- `/usr` - where most of the user space programs and data reside
  - `/usr/local`
  - `/usr/share`
- Kernel location
  - `/vmlinuz` or `/boot/vmlinuz`
  - boot loader loads this file into memory and sets it in motion when system boots
- Once boo loader starts the kernel, the main kernel file is no longer used by the running system
  - however, `loadable kernel modules` - modules loaded/unloaded by kernel
  - `/lib/modules`

### Superuser

- `/etc/sudoers`
- Use `visudo` to edit `/etc/sudoers`
- checks for syntax errors _after_ saving the file
- To check `sudo` logs, `journalctl SYSLOG_IDENTIFIER=sudo`

## Devices

### Device Files

- **device files** a.k.a. **device nodes**
  - under `/dev`
- `echo blah > /dev/null`
- File modes for devices:
  - `b` - block
  - `c` - character
  - `p` - pipe
  - `s` - socket
- Major vs. minor device numbers
- _NOT all_ devices have device files
  - e.g. network interfaces

#### Block Device

- data accessed in fixed chunks
- quick random access
- fixed size
- disks

#### Character Device

- data streams
- no fixed size
- printer

#### Pipe Device

- like character devices, but
  - with _another process_ at the other end of the I/O stream instead of kernel driver

#### Socket Device

- special-purpose interfaces for interprocess communication
- outside of `/dev`

### sysfs

- kernel assigns devices in the order in which devices are found
  - a device may have different names between reboots!
- the **sysfs** interface - provided by kernel
  - to provide uniform view for attached devices based on their _actual_ hardware attributes
  - path under `/sys/devices/`
- `/dev/` enables user processes to use the device
- `/sys/devices/` is used to view information and manage the device
- Use `udevadm` to show the sys path of a device under `/dev/`
  - `udevadm info --query=all --name=/dev/sda`

### `dd`

- `dd`
  - read from an input file/stream
  - write to an output file/stream
- `dd` copies data in blocks of fixed size
- uses an old IBM Job Control Language (JCL) syntax

### Device Name Summary

- To find the name of a device (when partitioning a disk)
  - query udevd using `udevadm` - the _ONLY_ reliable way
  - look for the device under `/sys/`
  - guess from the output of `journalctl -k`
    - prints kernel messages
  - guess from the output of kernel system log
  - if disk device already visible to system, check output of `mount`
  - run `cat /proc/devices` to see block/character devices for which the system has drivers

#### Hard Disks `/dev/sd*`

- `/dev/sda`, `/dev/sdb` etc - _entire_ disks
- `/dev/sda1`, `/dev/sda2`, etc - **partitions**
- `sd` - SCSI disk
  - **Small Computer System Interface (SCSI)**
- `lsscsi` - list SCSI devices
- Linux uses **Universally Unique Identifier (UUID)** and **Logical Volume Manager (LVM)** to maintain stable disk device mapping

#### Virtual Disks `/dev/xvd*` & `/dev/vd*`

- for virtual machines

#### Non-Volatile Memory Devices: `/dev/nvme*`

- talking to solid state storage
- `nvme list`

#### Device Mapper `/dev/dm-*` & `/dev/mapper/`

- **LVM**: a level up from disks and other direct block storage on some systems

#### CD/DVD drives `/dev/sr*`

- optical storage drives _might_ show up as PATA devices
- `/dev/sr*` devices are _read only_
- To write/rewrite optical devices, use "generic" SCSI devices such as `/dev/sg0`

#### PATA Hard Disks `/dev/hd*`

- **PATA (Parallel ATA)**
- `/dev/hda`, `/dev/hdb`, `/dev/hdc`, `/dev/hdd`
- If a SATA device recognized as PATA - it's running in compatibility mode
  - hindered performance
  - check your BIOS

#### Terminals: `/dev/tty*`, `/dev/pts/`, `/dev/tty`

- **Terminal** - device for moving characters between a user process and an I/O device
- _Most_ terminals are **pseudoterminal** devices
- Two common terminals:
  - `/dev/tty1` - the first virtual console
  - `/dev/pts/0` - the first pseudoterminal device
- `/dev/tty` - the controlling terminal of the current process
- use `getty` to launch a virtual console?
- force changing console: `# chvt 1` - switch to `tty1`

#### Audio Devices: `/dev/snd/*`, `/dev/dsp`, `/dev/audio`, etc

- Two sets of audio devices
  - **Advanced Linux Sound Architecture (ALSA)** - in `/dev/snd/`
  - **Open Sound System (OSS)**
    - computer will play any WAV file sent to `/dev/dsp`

#### Device File Creation

- You normally do _NOT_ create device files
  - created by **devtmpfs** and **udev**
- To manually create:
  - `mknod` - creates one device
    - `# mknod /dev/sda1 b 8 1`
      - block
      - major number 8
      - minor number 1
- Each system has a `MAKEDEV` program in `/dev/` to create groups of devices

### udev

#### devtmpfs

- the **devtmpfs filesystem** developed in response to the problem of device availability during boot
- kernel create device files as necessary, but also notifies udevd a new device is available
- udevd, upon receiving the signal, does _not_ create the device files, but
  - performs device initialization
  - sets permissions
  - notifies other processes that new devices are available
  - creates a number of symbolic links in `/dev/`
    - look for them in `/dev/disk/by-id/`
- the **tmp** in devtmpfs:
  - the filesystem resides in main memory,
  - with read/write capability by user-space processes

#### udevadm

- admin tool for udevd
- search for and explore system devices
- monitor uevents as udevd receives them from kernel

#### Device Monitoring

- `udevadm monitor`
- `udevadm monitor --kernel --subsystem-match=scsi`
  - see only kernel messages pertaining to changes in SCSI subsystem
- **udisksd** - daemon that listens for events in order to
  - automatically attach disks
  - notify other processes that new disks are available

### SCSI and Linux Kernel

- computer <-> SCSI Host Aapter <-> Devices
- **Serial Attached SCSI (SAS)**
  - newer version of SCSI
  - better performance
- Most likely USB storage devices that use SCSI commands
- SATA disks appear as SCSI devices
  - but most of them communicate through a translation layer
- NVMe devices are _NOT_ SCSI
  - but they could show up in `lsscsi` as adapter number `N`
- For any given device file on the system, kernel _almost always_ uses
  - one top-layer driver, and
  - one lower-layer driver

#### USB Storage and SCSI

- Linux kernel includes a three-layer USB subsystem closely resembling the SCSI subsystem
  - device-class driver
  - bus management core
  - host controller driver
- `lsusb`

#### Generic SCSI Devices

- `lsscsi -g`

## Disks And Filesystems

- **partition table**
  - where partitions are defined
  - a.k.a. **disk label**
- **Logical Volume Manager (LVM)**

### Partitioning Disk Devices

- traditionally, partition table is inside **Master Boot Record (MBR)**
- newer systems use **Globally Unique Identifier Table (GPT)**
- `parted` & `fdisk`

#### MBR

- contains the following partitions:
  - primary
  - extended
  - logical
- MBR has limit of 4 primary partitions
  - if more needed, one of them needs to be designated as **extended partition**
- extended partition breaks down into **logical partitions**
- `fdisk -l` - view system ID for an MBR

#### LVM Partitions

- partition labeled as LVM - partition type `8e`
- device named `/dev/dm-*`
- references to "device mapper"

#### Initial Kernel Read

- output like: `sda: sda1 sda2 < sda 5 >`
  - `/dev/sda2` is an extended partition containing one logical partition, `/dev/sda5`

#### Disk and Partition Geometry

- **cylinder-head-sector**
- **Logical Block Addressing (LBA)**

#### SSD

- **partition alignment**
- data read in **chunks**
- check partition boundary: `cat /sys/block/sdf/sdf2/start`

### File Systems

- **9P** from Plan 9
- **File System in User Space (FUSE)** - allows user-space filesystems in Linux
- **VFS (Virtual File System)**
  - allows Linux to support wide range of filesystems
- Use `mkfs` to create a filesystem
- `/mnt` - temporary mount point
- Mount filesystems by UUID
  - `blkid`
- Linux _buffers_ writes to the disk
- when unmounting using `unmount`, kernel _automatically_ synchronizes with the disk
  - writes the changes in buffer to the disk
  - can be forced using `sync`
- Difference between Unix & DOS text files - how lines end
  - Unix - only a linefeed `\n` marks the end of line
  - DOS - carriage return `\r` _followed by_ linefeed `\n`
- `/etc/fstab`
  - permanent list of filesystems & options
  - for mounting at boot time
  - maintained by the system
  - Simultaneously mount all entries in `/etc/fstab`
    - that do _NOT_ contain `noauto`
    - `# mount -a`
  - options:
    - `errors`
    - `noauto`
    - `user`
    - `defaults`
- `df` - view size & utilization of the currently mounted filesystems
  - `df <dir>`
  - e.g. `df .` - device holding the current directory
  - normally a certain percent (5%) of the total **capacity** is unaccounted for
    - **reserved** blocks
    - _only_ superuser can use
    - prevents system servers from immediately failing when run out of disk space
- `du` - disk usage of _every_ directory in the directory hierarchy
- POSIX defines a block size of **512** bytes
  - by default `df` and `du` output in 1024-byte blocks
  - use `POSIXLY_CORRECT` to display in 512-byte
- `fsck` - filesystem check
  - `e2fsck` for ext2/ext3/ext4
  - _NEVER_ use `fsck` on a _mounted_ filesystem!!!
  - `fsck -p` - auto fix ordinary problems
    - run by Linux at boot time
  - `fsck -n` - check the filesystem _without_ modifying anything
- normally `ext3` & `ext4` do not need to be checked manually
  - because they have **journals**
- `debugfs` - look through files on the filesystem and copy them elsewhere
  - opens filesystem in read-only mode
- Special filesystems
  - `proc` - mounted on `/proc`
  - `sysfs` - mounted on `/sys`
  - `tmpfs` - mounted on `/run` and others
  - `squashfs` - `/snap`
  - `overlay`

### Swap Space

- Pieces of idle programs swapped to the disk in exchange for active pieces residing on disk
- **swap space** - disk area used to store memory pages
- `free` - current swap usage in kb

#### Determine How Much Swap You Need

- Twice as real memory

### Logical Volume Manager

- `lvm`
- `vgs` - shows the volumes groups currently configured
- `lvs` - show logical volumes
- Once set up, logical volume block devices are available at
  - `/dev/dm-0`
  - `/dev/dm-1`
  - so on...
- `/dev/mapper/` - additional location for symbolic links

### Disk and User Space

- Kernel handles raw block I/O from devices
- User-space tools use the block I/O through device files
  - but _only_ for initializing operations
  - partitioning
  - filesystem creation
  - swap space creation

### Inside a Traditional Filesystem

- Two primary components:
  - pool of data blocks - to store data
  - database system that manages the data pool
    - **inode** data structure
- **inode**
  - a set of data that describes a particular file
- for any ext2/3/4 filesystem, start at inode `#2`, the **root node**
- `ls -i` - view inode numbers
- **unlinking**
- **block bitmap**
  - for the filesystem to determine which blocks are in use and which are free
  - 0 is free
  - 1 is in use
- when checking a filesystem, `fsck` walks through the inode table and directory structure
  - generates new link counts and a new block bitmap
  - compares with the filesystem on disk
  - make orphans in the filesystem's `lost+found` directory

## How Linux Kernel Boots

### Overview

1. Machine's BIOS or boot firmware loads & runs boot loader
2. Boot loader finds the kernel image on disk, loads it into _memory_, and starts it
3. Kernel initializes devices and drivers
4. Kernel mounts the root filesystem
5. Kernel starts the `init` program, with PID of 1 - **user space start**
6. `init` sets rest of the system processes in motion
7. `init` at some point starts a process allowing for user log in - usually at (or near) end of boot sequence

### Startup Messages

- `journalctl` - best way to view kernel's boot & runtime diagnostic messages
  - `journalctl -k` - for the current boot
  - `journalctl -b` - previous boots
- `dmesg` - view kernel messages in the **kernel ring buffer**
- **systemd** captures diagnostic messages from startup & runtime that would normally go to the console

### Kernel Initialization and Boot Options

- Order:
  1. CPU inspection
  2. Memory inspection
  3. Device bus discovery
  4. Device discovery
  5. Auxiliary kernel subsystem setup (networking etc)
  6. Root filesystem mount
  7. User space start
- Example from my `journalctl -k`:

```bash
Jan 07 15:55:20 nixos kernel: Freeing unused decrypted memory: 2028K
Jan 07 15:55:20 nixos kernel: Freeing unused kernel image (initmem) memory: 2956K
Jan 07 15:55:20 nixos kernel: Write protecting the kernel read-only data: 24576k
Jan 07 15:55:20 nixos kernel: Freeing unused kernel image (rodata/data gap) memory: 988K
Jan 07 15:55:20 nixos kernel: x86/mm: Checked W+X mappings: passed, no W+X pages found.
Jan 07 15:55:20 nixos kernel: Run /init as init process
Jan 07 15:55:20 nixos kernel:   with arguments:
Jan 07 15:55:20 nixos kernel:     /init
Jan 07 15:55:20 nixos kernel:   with environment:
Jan 07 15:55:20 nixos kernel:     HOME=/
Jan 07 15:55:20 nixos kernel:     TERM=Linux
```

### Kernel Parameters

- text-based
- To view parameters passed to currently running kernel: `/proc/cmdline`
- `ro` - mount root filesystem in read-only mode
  - easier for `fsck` to check
  - then remounts root filesystem in read-write mode

### Boot Loaders

- Loads the kernel into memory from somewhere on a disk and then starts with a set of kernel parameters
- To access the disk
  - uses BIOS (Basic Input/Output System) or **UEFI** (Unified Extensible Firmware Interface)
  - BIOS/UEFI uses **Logical Block Addressing (LBA)** to access attached storage hardware

### GRUB

- Filesystem navigation
- `initrd` - filesystem of RAM
- the GRUB **root**
  - filesystem where GRUB searches for kernel and RAM filesystem image files

### UEFI

- **secure boot**
- supports installing _multiple_ boot loaders in the EFI partition

### Chainloading Other OS

- provided by GRUB

### Boot Loader Details

- **MBR** & **UEFI**

#### MBR Boot

- **multistage boot loader**

#### UEFI Boot

- GPT partitioning scheme is part of UEFI
- always a special VFAT filesystem called **EFI System Partition (ESP)**
  - contains a directory **EFI**
  - mounted at `/boot/efi`

## How User Space Starts

- Roughly in the order of:
  1. init
  2. essential low-level services - udevd, syslogd, etc
  3. network configuration
  4. mid- & high-level services (cron, printing, etc)
  5. login prompts, GUIs, high-level applications (web servers etc)

### init

- main purpose: to start/stop essential service processes
- standard implementation: **systemd**
- `/etc/systemd/`

### systemd

- advanced service management capabilities:
  - manage file system mounts
  - monitor network connection requests
  - run timers
- **unit**: each specific function
- **unit type**: each capability
- Most significant unit types:
  - **service units**
  - **target units**
  - **socket units**
  - **mount units**

#### Booting

- activating a _default_ unit - `default.target`
- `systemd-analyze dot` - create dependency graph

#### systemd config

- two main locations:
  - **system unit**: `/lib/systemd/system` or `/usr/lib/systemd/system`
  - **system configuration**: `/etc/systemd/system/`
- To check current systemd config search path: `systemctl -p UnitPath show`
- Unit files

#### Operation

- through `systemctl`
- `systemctl list-units`
  - default command
  - `--full`
  - `--all`
- To view _all_ of a unit's messages:
  - `journalctl --unit=<unit_name>`

#### systemd dependencies

- `Requires` vs. `Wants`

#### systemd on-demand and resource-parallelized startup

- `<name>@.service` supports _multiple simultaneous_ instances

### Shutting Down

- controlled by init
- if `shutdown` other than `now`
  - creates a `/etc/nologin`

### Initial RAM Filesystem

- **initramfs**
- `initrd`

## System Time, Batch Jobs, and Users

- `/etc/` - system's configuration

### System Logging

- **syslog**
  - replaced by **journald**
- **rsyslogd**
  - `/etc/rsyslog.conf`
- `journalctl`
  - `journalctl -S -4h` - since the last 4hr
  - `-U` - until
  - `-u` - filter by unit `<name>.service`
  - `journalctl -g 'kernel.*memory'` - search by text
  - `journalctl -b` - since the start of current boot
  - `journalctl -b -1` - since the start of previous boot
  - `-f` - print logs as they arrive - live feed
- `logrotate`

### Structure of `/etc/`

- for system configuration files
- Guideline: customizable configurations for a single machine
  - user information, `/etc/passwd`
  - network details `/etc/network`
- Nowadays passwords are stored in the **shadow** file, `/etc/shadow`
- **pseudo-users**: users that cannot log in
- **Pluggable Authentication Modules (PAM)**
- To add/remove users,
  - `adduser`
  - `userdel`
- To _directly_ edit `/etc/passwd`
  - `vipw` - backs up and locks `/etc/passwd`
  - `vipw -s` - modifies `/etc/shadow` directly

### `getty`

- attaches to terminals and displays a login prompt
- After entering the login name,
  - `getty` replaces itself with `login` program, asking for password
  - if correct password entered, `login` replaces itself (using `exec()`) with your shell
- Much of the `login` program's real authentication work is handled by **PAM**

### Time

- **system clock** - maintained by kernel
- **Real-Time Clock (RTC)**
  - battery-backed
  - included in PC hardware
  - kernel sets its time based on RTC at boot time
- **time drift** - corrected by `adjtimex`
- `tzselect`
- **Network Time Protocol (NTP)**
  - used to be handled by **ntpd** daemon, but replaced by systemd's **timesyncd**

### Scheduling Recurring Tasks with cron and Timer Units

- systemd's **timer units** are alternative to cron

### `at`

- run job _once_ in the future
- `atq` - check the scheduled job
- to remove scheduled jobs, `atrm`
- `systemd-run`

### Timer Units Running as Regular Users

- `systemd-run --user`
- to keep the user manager around after logging out: `loginctl enable-linger`

### User Access

- **effective user ID (euid)** vs. **real user ID (ruid)**
  - euid: access rights for a process (e.g. file permissions)
    - _actor_ of a process
  - ruid: who initiated a process
    - _owner_ of a process
- when a setuid program is being run, Linux sets euid to the program's owner during execution
- `sudo` (and many other setuid programs) explicitly change the euid _and_ ruid with one of the `setuid()` syscalls

### Pluggable Authentication Modules

- by Sun
- dynamically loadable **authentication modules**

## Processes And Resource Utilization

### Tracking Processes

- `top`
  - send keystrokes within `top` to change view
  - _case-sensitive_

### Finding Open Files with `lsof`

- `lsof` - list open files and processes using them

### Tracing Program Execution and System Calls

- `strace` - system call trace
  - begins working on the _new_ process (the copy of the original process) just after the `fork()` call
  - can be used on daemons that fork/detach themselves
- `ltrace` - library trace
  - does _not_ track anything on kernel level
  - many _more_ shared lib calls than sys calls

### Threads

- _all_ threads inside a single process share their system resources and _some_ memory
- separate processes _usually_ do _not_ share system resources
  - memory
  - I/O
- multiple threads (within a process) can run _simultaneously_ on multiple processors
- threads start _faster_ than processes
- threads (within a process) intercommunicate faster
  - shared memory

#### Viewing Threads

- `ps` and `top` by default _only_ show processes
  - `ps m` to show threads

### Resource Monitoring

- `top -p <pid1> [-p pid2 ...]` - monitor one/more specific processes _over time_
- `time` - how much CPU time a command uses during its lifetime
  - system's version: `/usr/bin/time`
- `user` - number of seconds the CPU has spent during the program's own code
- `sys`/`system` - how much time the kernel spends doing the process's work
- `real` - **elapsed time**
  - total time from start to finish
  - including CPU time doing other tasks
- `top`
  - `PR` column - priority
  - nice value - how nice you are being to other processes
- `renice <nice_value> <pid>`
- **load average**
  - average number of processes currently ready to run
  - if it's `1`, a single process is probably using the CPU nearly all of the time
- To check memory usage status:
  - `free`
  - view `/proc/meminfo` - how much memory is being used for caches and buffers
- How memory works
  - CPU has a memory management unit (MMU) to add flexibility to memory access
  - kernel assists MMU by breaking down the memory _used by processes_ into smaller chunks, **pages**
  - kernel maintains **page table**
    - mapping a process's virtual page addresses to real page addresses in memory
  - as process accessing memory, MMU translates the virtual addresses (used by process) into real addresses based on the kernel's page table
- **on-demand paging**, a.k.a. **demand paging**
  - kernel loads & allocates pages as a process needs them
- `getconf PAGE_SIZE` - system's page size
  - `4096`, or 4k, on most Linux distros
- Page faults
  - minor
  - major
    - might occur when kernel needs to load the program from the disk (swap) the first time
- `vmstat`
- `iostat`
- `iotop` - I/O resources used by individual processes
  - processes using the most I/O
  - displays _threads_ instead of processes
  - scheduling classes:
    - `be` - best effort, where most processes run under
    - `rt` - real-time, higher priority than any other class
    - `idle`
- `ionice` - change I/O priority
- `pidstat` - monitor resource consumption of a process _over time_

### Control Groups

- **cgroup** - a kernel feature
  - in kernel space
  - does _NOT_ depend on systemd
- **controllers** - how the processes within one cgroup behave
  - `cpu`
  - `memory`
- `/proc/<pid>/cgroup` - view the cgroup file
- `/sys/fs/cgroup/` - view cgroups
- see the current resource utilization in this cgroup - `cat cpu.stat`

## Network and Its Configuration

### Packets

- **packet**
  - **header**
  - **payload**

### Network Layers

- in Linux, **transport layer** and all layers below are _primarily_ handled by the kernel

### Internet Layer

- `ip address show` - to view your IP
  - look at `inet` for IPv4 address
- **Classless Inter-Domain Routing (CIDR)**
  - number of _leading_ `1`s in the subnet mask

### Routes and the Kernel Routing Table

- `ip route show` - to view the routing table

### Default Gateway

- `default` in the routing table - matches _any_ address on Internet
  - `0.0.0.0/24` for IPv4
- **default gateway** - as intermediary for the default route
- kernel _always_ picks the route with the longest destination prefix that matches
  - CIDR

### IPv6

- **subnet** & **interface ID**
- Hosts normally have _at least two addresses_
  - **global unicast address**
  - **link-local address**
- `ip -6 address show`
  - `scope global`
  - `scope link`
- `ip -6 route show`

### ICMP and DNS

- `ping` - send ICMP echo request
- `host` - find the IP behind a domain name

### Kernel Network Interfaces

- **predictable network interface device**
- at boot time, interfaces have traditional names `eth0` and `wlan0`
  - but quickly renamed on systemd machines
- **link/ether** - MAC address

### Resolving Hostnames

- DNS is in the application layer, entirely user space
- check for manual override in `/etc/hosts`, _before_ going DNS
- `/etc/resolv.conf`
  - traditional config file for DNS server
- DNS caching
  - `systemd-resolved` - routers acting as name servers
  - BIND - the standard Unix name server daemon
- `resolvectl status` - check the current DNS settings
- `/etc/nsswitch.conf`
  - traditional interface for controlling several name-related precedence settings
  - `hosts:    files dns`
  - make sure `/etc/hosts` is as short as possible
  - RULE:
    > If a particular host has a DNS entry, it has _NO_ place in `/etc/hosts`

### Localhost

- `lo` - virtual network interface, **loopback**

### TCP and UDP

- `netstat -nt` - view active connections
  - `-n` - disables DNS
  - `-t` - limits output to TCP
- `/etc/services` - file for well known ports
- on Linux, _only_ processes running as _superuser_ can use ports 1 through 1023
- UDP
  - defines transport _only_ for single messages
  - _NO_ data stream
  - has ports
  - _NO_ connections
  - _does_ have error detection _inside_ a packet
    - but does _NOT_ have to do anything about it

### DHCP

- You get:
  - IP address
  - subnet mask
  - default gateway
  - DNS server
- when making an initial DHCP request, a host _broadcasts_ the request to _all_ hosts (on its physical network)
  - since it does not know the address of its DHCP server

#### Linux DHCP Clients

- `dhclient` - traditional
  - stores its PID in `/var/run/dhclient.pid`
  - stores lease info in `/var/lib/dhcp/dhclient.leases`
- systemd-networkd has a built-in DHCP client

### Ethernet, IP, ARP, and NDP

- **Address Resolution Protocol (ARP)**
  - maintains a small table, ARP cache
  - maps IP addresses to MAC addresses
  - in the kernel

## Network Applications and Services

- `lsof` - list programs currently using or listening to ports
  - `-n` - disable resolution
  - `lsof -i:<port>` - filter by port
  - `lsof -i<protocol>@<host>:<port>`
- `tcpdump`
  - puts the network interface card into **promiscuous mode**
  - reports on every packet that comes across
  - `tcpdump tcp`
  - Wireshrak - GUI alternative
- `netcat` or `nc`
- `nmap` - network mapper
  - scans _all_ ports on a machine or network of machines, looking for open ports

### Remote Procedure Calls

- **RPC** - remote procedure call
- where a client program calls functions that execute on a remote server

### Network Security

- The following services should _always_ be deactivated:
  - **ftpd**
  - **telnetd**
  - **rlogind**
  - **rexecd**

### Network Sockets

- On Unix, a process uses a **socket** to identify when & how it's talking to the network
- **sockets** - the interface that processes use to access the network through kernel
  - boundary between user space & kernel space
- `SOCK_STREAM` - stream sockets for TCP
- `SOCK_DGRAM` - datagram sockets for UDP

### Unix Domain Sockets

- special kind of socket
- when a process connects to a Unix domain socket,
  - it can listen for and accept connections on the socket
- _NOT_ a network socket
  - _NO_ network behind it
- **D-BUS**
- `lsof -U` - view Unix domain sockets currently in use

## Network File Transfer and Sharing

### Quick Copy

- `python -m SimpleHTTPServer`
- `scp -r <directory> <user>@<remote_host>[:dest_dir]`

### rsync

- `rsync -nva dir host:dest_dir` - copy a directory to a different dir on remote host
  - `-a` - all files
  - `-n` - dry run mode
  - `-v` - verbose
- _NOTE_ the different between slash and no-slash!
  - `dir` vs `dir/`

### SSHFS

- `sshfs username@host:dir mountpoint`
  - user-space filesystem
  - to unmount: `fusermount -u <mountpoint>`

### NFS

- commonly used traditional systems for file sharing among UNIX systems
- can be served over TCP & UDP

## User Env

- `/usr/bin/` - where most Linux distros install executables
- For a user's own shell scripts
  - `$HOME/bin`
  - `$HOME/.local/bin`
- You should _NEVER_ put a dot (`.`) at the _front_ of the path
- `$MANPATH`
- **login shell** vs. **non-login shell**
- `$-` - current set of options in the current shell
- `tcsh`
- `$PAGER` - default to `less`
- startup file pitfalls
  - do _NOT_ set `$DISPLAY` env variable in a shell startup file
  - do _NOT_ set terminal type in a shell startup file
  - _NEVER_ set `$LD_LIBRARY_PATH` in a shell startup file

## Linux Desktop

### Desktop Components

- **Framebuffer**
  - fundamental of any graphical display mechanism
  - a chunk of memory that the graphics hardware reads and transmits to screen for display

#### X Window System

- X **client** programs handle UI
- X **server** serves as kernel, managing
  - rendering windows
  - configuring displays
  - handling input from devices

#### Wayland

- **decentralized** by design
- each client gets:
  - its own memory buffer for its own window
  - **compositor**

### Wayland

- Wayland refers to a **communication protocol** between compositing window manager and graphical client program
- `$WAYLAND_DISPLAY` - unix domain socket for communication with clients
  - found in `/run/user/<uid>/`
- `libinput` - inspect input devices & events as they are presented by kernel

#### X Compatibility in Wayland

- Two approaches:
  - add Wayland support to the app
  - run X app through a compatibility layer in Wayland
    - `Xwayland`

### X

- **X display**
- On Linux, X server runs on a virtual terminal
- can run clients across a network to a server running on a different machine directly over the network
  - X server listening for TCP connections on port 6000
- X Events
  - `xev`

### D-Bus

- **Desktop Bus** - a message-passing system
- interprocess communication mechanism
  - allows desktop apps to talk to each other
- `dbus-daemon` - central hub
  - accepts and retransmits events
- Two kinds of `dbus-daemon` instances (processes)
  - the **system instance**
    - started by init at boot time
    - processes connect to it through `/var/run/dbus/system_bus_socket` UNIX domain socket
  - the **session instance**
    - optional
    - runs _only when_ a desktop session is started
    - desktop apps connect to this instance

## Development Tools

- `ld` - run the linker
  - creates executable from object files
  - `cc -l<lib>` - link against a library
    - note there is no space between `-l` and `<lib>`
  - `cc -L<non-stardard-lib>`
- `nm --defined-only <lib>` - search a lib for a particular function
- `libc.a` - basic file in the standard C lib
- `<lib>.a` - **static** library
  - linker copies necessary machine code from lib file into executable
- **shared** libraries - only **references** to names in the code of the lib file
  - when program is run, system loads the lib's code into the process memory space _only when_ necessary
  - `.so`
  - `ldd <program>` - to see what share libs a program uses
    - output format: `<shared-lib-name> => <shared-lib-location>`
  - `ld.so` - **runtime dynamic linker/loader**
    - small program that finds & loads shared libs for a program at _runtime_
    - provides right side of `=>` from output of `ldd`
- How `ld.so` finds shared libs
  - first place to look at: executable's runtime library search path (**rpath**)
  - next: system cache, `/etc/ld.so.cache`
    - fast cache of names of lib files found in the **cache configuration file**, `/etc/ld.so.conf`
      - you should _NOT_ modify it
    - if `/etc/ld.so.conf` altered, need to rebuild `/etc/ld.so.cache` by doing `ldconfig -v`
  - another place: `LD_LIBRARY_PATH`
- To link shared libs
  - `cc -o <exec> <exec.o> -Wl,-rpath=<path-to-shared-lib> -L<path-to-shared-lib>`
  - `-Wl,-rapth` tells linker to include the specified dir into executable's lib search path
  - `-L` is _still_ needed
- `patchelf` - change the runtime lib search path of an _existing_ binary
  - although better done at compile time
  - **ELF (Executable and Linkable Format)**
- _NEVER_ set `LD_LIBRARY_PATH` in shell startup files or when compiling software
  - if you _have to_ set it, do it in a wrapper script
- Working with header (include) files and dirs
  - `/usr/include` - default include dir
  - `cc -c -I/<path-to-include-dir> <file>.c`
- `#include "header.h"` vs. `#include <header.h>`
  - double quotes - the header file is _not_ in a system include directory
- Preprocessor
  - passing the compiler `-D<MACRO_NAME>=<value>` === `#define <MACRO_NAME> <value>`
- **Lex**: a **tokenizer** that transforms text into numbered tags with labels
  - `flex` - the GNU version
- **Yacc**: a **parser** that attempts to read tokens according to a **grammar**
  - `bison` - GNU version

## Virtualization

### Virtual Machines

- **system virtual machine**
  - IBM mainframe
- **Hypervisor**
  - manages one/more virtual machines
  - Two types:
    - **type 1 hypervisor**
      - similar to an OS
      - with kernel
      - **Xen**
    - **type 2 hypervisor**
- **host** vs. **guest**
- **paravirtualization**
- Virtual machine CPU modes
  - kernel mode vs. user mode
  - hypervisor can detect & react to (**trap**) any restricted instructions coming from a virtual machine
  - hypervisor can emulate the restricted instructions, enabling VMs to run in kernel mode

### Containers

- lighter weight than VM
- service isolation
  - `chroot()` - change root dir to something other than actual sys root
    - **chroot jail**
- **container**: a restricted runtime env for a set of processes
  - the processes _cannot_ touch anything on the system outside the env
  - **OS level virtualization**
- docker vs podman
