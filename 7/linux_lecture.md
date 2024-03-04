## Chapter 6: How User Space Starts
User space starts in roughly this order:

    1. init
    2. Essential low-level services such as udevd and syslogd
    3. Network configuration
    4. Mid-level and high-level services (cron, printing, and so on)
    5. Login prompts, GUIs, and other high-level applications
    
### Introduction to init
The init program is a user-space program like any other program on the Linux system, and you’ll find it in _/sbin_ 
along with other system binaries. Its main purpose is to start and stop the essential service processes on the system.
There are three major implementations:

    * System V init: A traditional sequenced init (RHEL and others)
    * systemd: The emerging standard for init
    * Upstart The init on Ubuntu installations (to be deprecated in favour of systemd)
    
### System V Runlevels
At any given time on a Linux system, a certain base set of processes (such as crond and udevd) is running. In System
V init, this state of the machine is called its runlevel, which is denoted by a number from 0 through 6. You can 
check your system’s runlevel with the `who -r` command 

### Identifying your init

    * If your system has /usr/lib/systemd and /etc/systemd directories, you have systemd
    * If you have an /etc/init directory that contains several .conf files, you’re probably running Upstart
    * If neither of the above is true, but you have an /etc/inittab file, you’re probably running System V init
    
### systemd
The systemd init handles the regular boot process and aims to incorporate a number of standard Unix services (cron, 
inetd). It has the ability to defer the start of services and operating system features until they are necessary.