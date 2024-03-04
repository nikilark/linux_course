## Chapter 5: How the Linux Kernel Boots<a name="Chapter5"></a>
A simplified view of the boot process looks like this:

    1. The machine’s BIOS or boot firmware loads and runs a boot loader
    2. The boot loader finds the kernel image on disk, loads it into memory, and starts it
    3. The kernel initializes the devices and its drivers
    4. The kernel mounts the root filesystem
    5. The kernel starts a program called init with a process ID of 1. This point is the user space start
    6. init sets the rest of the system processes in motion
    7. At some point, init starts a process allowing you to log in, usually at the end or near the end of the boot
    
### Startup Messages
There are two ways to view the kernel’s boot and runtime diagnostic messages:

    * Look at the kernel system log file in _/var/log/kern.log_
    * Use the dmesg command (use less to view the output)
    
### Kernel Initialization and Boot Options
Upon startup, the Linux kernel initializes in this general order:

    * CPU inspection
    * Memory inspection
    * Device bus discovery
    * Device discovery
    * Auxiliary kernel subsystem setup (networking, and so on)
    * Root filesystem mount
    * User space start
    
### Kernel Parameters
When running the Linux kernel, the boot loader passes in a set of text-based kernel parameters that tell the kernel 
how it should start. These parameters are at _/proc/cmdline_. The most important parameter is the _root_ parameter, 
which is the location of the root filesystem (without it, the kernel cannot find init and therefore cannot perform 
the user space start). 
Upon encountering a parameter that it does not understand, the Linux kernel saves the parameter. The kernel later 
passes the parameter to init when performing the user space start.

### Boot Loaders
A boot loader starts the kernel and starts it with a set of parameters. The kernel and its parameters are usually 
somewhere on the root filesystem, and even when the kernel parameters or disk drivers hasn't been loaded, it is 
possible to load the kernel because nearly all disk hardware has firmware that allows the BIOS to access attached 
storage hardware with Linear Block Addressing (LBA). 

#### Boot Loader Tasks
A Linux boot loader’s core functionality includes the ability to do the following:

    * Select among multiple kernels
    * Switch between sets of kernel parameters
    * Allow the user to manually override and edit kernel image names and parameters (i.e. to enter single-user mode)
    * Provide support for booting other operating systems
    
#### GRUB Introduction
GRUB (Grand Unified Boot Loader) is a near-universal standard on Linux systems and has a filesystem navigation that 
allows for much easier kernel image and configuration selection. GRUB doesn’t really use the Linux kernel, it starts it.
    
#### Exploring Devices and Partitions with the GRUB Command Line
GRUB has its own device-addressing scheme, named hdx where x is 0,1... GRUB has also a command line (access it by 
pressing C at the boot menu), where you can do:

    * ls -l: listing command, details the list of devices known to grub
    * set: View the currently set grub variables
    * ls ($root)/: The previous command displays information about the root partition
    * ls ($root)/boot: Boots from the partition in root
    
#### GRUB Configuration
The GRUB configuration directory contains the central configuration file (grub.cfg) and numerous loadable modules with a
_.mod_ suffix. The directory is usually _/boot/grub_ or _/boot/grub2_. Use _grub-mkconfig_ command to modify this file. 

##### Reviewing the Grub.cfg

the grub.cfg file consists of GRUB commands, which usually begin with a number of initialization steps followed by a
 series of menu entries for different kernel and boot configurations. Later in this file you should see the 
 available boot configurations, each beginning with the _menuentry_ command.
 
##### Generating a New Configuration File
To make changes to your GRUB configuration, add your new configuration elsewhere, then run `grub-mkconfig` to generate
 the new configuration. Every file in /etc/grub.d is a shell script that produces a piece of the grub.cfg file. The 
 `grub-mkconfig` command itself is a shell script that runs everything in _/etc/grub.d_.
 
#### GRUB Installation
##### Installing GRUB on Your System
GRUB comes with a utility called _grub-install_, which performs most of the work of installing the GRUB files and 
configuration for you.

##### Installing GRUB on an External Storage Device
To install GRUB on a storage device outside the current system, you must manually specify the GRUB directory on that
 device as your current system now sees it: `grub-install --boot-directory=<origin> <target>`
  
##### Installing GRUB with UEFI
UEFI installation is supposed to be easier, because you all you need to do is copy the boot loader into place. But 
you also need to “announce” the boot loader to the firmware with the _efibootmgr_ command: 
`grub-install --efi-directory=efi_dir –-bootloader-id=name`

### Chainloading Other Operating Systems
UEFI makes it relatively easy to support loading other operating systems because you can install multiple boot 
loaders in the EFI partition but the older MBR style doesn’t support it.

### Boot Loader Details
#### MBR Boot
The Master Boot Record (MBR) includes a small area (441 bytes) that the PC BIOS loads and executes after its Power-On
 Self-Test (POST), but usually additional space is necessary, resulting in what is sometimes called a multi-stage 
 boot loader (MBR does nothing other than load the rest of the boot loader code).
 
#### UEFI Boot
The Extensible Firmware Interface (EFI) which current standard is Unified EFI (UEFI) consists on a special filesystem 
called the EFI System Partition (ESP), which contains a directory named efi. Each boot loader has its own identifier 
and a corresponding subdirectory. A boot loader file has an .efi extension and resides in one of these 
subdirectories, along with other supporting files.

#### How GRUB Works
In summary, GRUB does the following:

    1. The PC BIOS or firmware initializes the hardware and searches its boot-order storage devices for boot code
    2. Upon finding the boot code, the BIOS/firmware loads and executes it. This is where GRUB begins
    3. The GRUB core loads
    4. The core initializes. At this point, GRUB can now access disks and filesystems
    5. GRUB identifies its boot partition and loads a configuration there
    6. GRUB gives the user a chance to change the configuration
    7. After a timeout or user action, GRUB executes the configuration
    8. In the course of executing the configuration, GRUB may load additional code (modules) in the boot partition
    9. GRUB executes a boot command to load and execute the kernel as specified by the configuration’s linux command
    