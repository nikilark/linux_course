# Розділ 13: Віртуалізація 

The word _virtual_ can be vague in computing systems. It’s used primarily to indicate an intermediary that translates a complex or fragmented underlying layer to a simplified interface that can be used by multiple consumers.

Consider an example that we’ve already seen, virtual memory, which allows multiple processes to access a large bank of memory as if each had its own insulated bank of memory.

![Virtual Memory](images/virtual_memory.png)

That definition is still a bit daunting, so it might be better to explain the typical purpose of virtualization: creating isolated environments so that you can get multiple systems to run without clashing.

Because virtual machines are relatively easy to understand at a higher level, that’s where we’ll start our tour of virtualization.

## Virtual Machines

Virtual machines are based on the same concept as virtual memory, except with _all_ of the machine’s hardware instead of just memory. In this model, you create an entirely new machine (processor, memory, I/O interfaces, and so on) with the help of software, and run a whole operating system in it—including a kernel. This type of virtual machine is more specifically called a _system virtual machine_, and it’s been around for decades.

For example, IBM mainframes traditionally use system virtual machines to create a multiuser environment; in turn, users get their own virtual machine running CMS, a simple single-user operating system.

You can construct a virtual machine entirely in software (usually called an _emulator_) or by utilizing the underlying hardware as much as possible, as is done in virtual memory.

![Virtual Machine](images/vm.png)

### Hypervisors

Overseeing one or more virtual machines on a computer is a piece of software called a _hypervisor_ or _virtual machine monitor (VMM)_, which works similarly to how an operating system manages processes. There are two types of hypervisors, and the way you use a virtual machine depends on the type.

To most users, the _type 2 hypervisor_ is the most familiar, because it runs on a normal operating system such as Linux. For example, VirtualBox is a type 2 hypervisor, and you can run it on your system without extensive modifications.

On the other hand, a _type 1 hypervisor_ is more like its own operating system (especially the kernel), built specifically to run virtual machines quickly and efficiently. This kind of hypervisor might occasionally employ a conventional companion system such as Linux to help with management tasks.

Even though you might never run one on your own hardware, you interact with type 1 hypervisors all the time. All cloud computing services run as virtual machines under type 1 hypervisors such as Xen. When you access a website, you’re almost certainly hitting software running on such a virtual machine. 

_Creating an instance of an operating system on a cloud service such as AWS is creating a virtual machine on a type 1 hypervisor._

In general, a virtual machine with its operating system is called a _guest_. The _host_ is whatever runs the hypervisor. For type 2 hypervisors, the host is just your native system. For type 1 hypervisors, the host is the hypervisor itself, possibly combined with a specialized companion system.

### Hardware in a Virtual Machine

In theory, it should be straightforward for the hypervisor to provide hardware interfaces for a guest system.

For example, to provide a virtual disk device, you could create a big file somewhere on the host and provide access as a disk with standard device I/O emulation. This approach is a strict hardware virtual machine; however, it is inefficient. 

Most of the differences you might encounter between real and virtual hardware are a result of a bridging that allows guests to access host resources more directly. Bypassing virtual hardware between the host and guest is known as _paravirtualization_.

Network interfaces and block devices are among the most likely to receive this treatment; for example, a _/dev/xvd_ device on a cloud computing instance is a Xen virtual disk, using a Linux kernel driver to talk directly to the hypervisor.

#### Virtual Machine CPU Modes

The specific names of these modes vary depending on the processor (for example, the x86 processors use a system called _privilege rings_), but the idea is always the same. In kernel mode, the processor can do almost anything; in user mode, some instructions are not allowed, and memory access is limited.

The first virtual machines for the x86 architecture ran in user mode. This presented a problem, because the kernel running inside the virtual machine wants to be in kernel mode. To counter this, the hypervisor can detect and react to (“trap”) any restricted instructions coming from a virtual machine.

With a little work, the hypervisor emulates the restricted instructions, enabling virtual machines to run in kernel mode on an architecture not designed for it. Because most of the instructions a kernel executes aren’t restricted, those run normally, and the performance impact is fairly minimal.

Soon after the introduction of this kind of hypervisor, processor manufacturers realized that there was a market for processors that could assist the hypervisor by eliminating the need for the instruction trap and emulation. Intel and AMD released these feature sets as VT-x and AMD-V, respectively, and most hypervisors now support them. In some cases, they are required.

### Common Uses of Virtual Machines

In the Linux world, virtual machine use often falls into one of a few categories:

1.  Testing and trials There are many use cases for virtual machines when you need to try something outside of a normal or production operating environment. For example, when you’re developing production software, it’s essential to test software in a machine separate from the developer’s. Another use is to experiment with new software, such as a new distribution, in a safe and “disposable” environment. Virtual machines allow you to do this without having to purchase new hardware.
2.  Application compatibility When you need to run something under an operating system that differs from your normal one, virtual machines are essential.
3.  Servers and cloud services As mentioned earlier, all cloud services are built on virtual machine technology. If you need to run an internet server, such as a web server, the quickest way to do so is to pay a cloud provider for a virtual machine instance. Cloud providers also offer specialized servers, such as databases, which are just preconfigured software sets running on virtual machines.

### Drawbacks of Virtual Machines

*   _It can be cumbersome and time-consuming to install and/or configure the system and application_. Tools such as Ansible can automate this process, but it still takes a significant amount of time to bring up a system from scratch.
*   _Even when configured properly, virtual machines start and reboot relatively slowly_.
*   _You have to maintain a full Linux system, keeping current with updates and security on each virtual machine_.
*   _Your application might have some conflicts with the standard software set on a virtual machine_.
*   _Isolating your services on separate virtual machines can be wasteful and costly_.

## Runtime-Based Virtualization

The reason for this virtualization is that multiple applications on the same system can use the same programming language, causing potential conflicts. For example, Python is used in several places on a typical distribution and can include many add-on packages. If you want to use the system’s version of Python in your own package, you can run into trouble if you want a different version of one of the add-ons.

Let’s look at how Python’s virtual environment feature creates a version of Python with only the packages that you want. The way to start is by creating a new directory for the environment like this:

    $ python3 -m venv test-venv

Now, look inside the new _test-venv_ directory. You’ll see a number of system-like directories such as _bin_, _include_, and _lib_. To activate the virtual environment, you need to source (not execute) the `test-venv/bin/activate` script:

    $ . test-env/bin/activate

The reason for sourcing the execution is that activation is essentially setting an environment variable, which you can’t do by running an executable. At this point, when you run Python, you get the version in _test-venv/bin_ directory (which is itself only a symbolic link), and the `VIRTUAL_ENV` environment variable is set to the environment base directory. You can run `deactivate` to exit to the virtual environment.

![Virtual Environment](images/venv.jpg)

It isn’t any more complicated than that. With this environment variable set, you get a new, empty packages library in _test-venv/lib_, and anything new you install when in the environment goes there instead of in the main system’s library.

## Containers

Virtual machines are great for insulating an entire operating system and its set of running applications, but sometimes you need a lighter-weight alternative to put up barriers around server daemons, especially when you don’t trust one of them very much. Container technology is now a popular way to fulfill this need.  

One method of service isolation is using the `chroot()` system call to change the root directory to something other than the actual system root. This type of isolation is sometimes called a _chroot jail_ because processes can’t (normally) escape it.

Another type of restriction is the resource limit (rlimit) feature of the kernel, which restricts how much CPU time a process can consume or how big its files can be.

_Container_ can be loosely defined as a restricted runtime environment for a set of processes, the implication being that those processes can’t touch anything on the system outside that environment. In general, this is called _operating system–level virtualization_.

![Container](images/docker.webp)

It’s important to keep in mind that a machine running one or more containers still has only one underlying Linux kernel. However, the processes inside a container can use the user-space environment from a Linux distribution different than the underlying system.

The restrictions in containers are built with a number of kernel features. Some of the important aspects of processes running in a container are:

*   They have their own cgroups.
*   They have their own devices and filesystem.
*   They cannot see or interact with any other processes on the system.
*   They have their own network interfaces.

### LXC

The term _LXC_ is sometimes used to refer to the set of kernel features that make containers possible, but most people use it to refer specifically to a library and package containing a number of utilities for creating and manipulating Linux containers.

Unlike Docker, LXC involves a fair amount of manual setup. For example, you have to create your own container network interface, and you need to provide user ID mappings.

Originally, LXC was intended to be as much of an entire Linux system as possible inside the container—init and all. After installing a special version of a distribution, you could install everything you needed for whatever you were running inside the container.

Therefore, you might find LXC more flexible in adapting to different needs.

### Kubernetes

Speaking of management, containers have become popular for many kinds of web servers, because you can start a bunch of containers from a single image across multiple machines, providing excellent redundancy.

Unfortunately, this can be difficult to manage. You need to perform tasks such as the following:

*   Track which machines are able to run containers.
*   Start, monitor, and restart containers on those machines.
*   Configure container startup.
*   Configure the container networking as required.
*   Load new versions of container images and update all running containers gracefully.

Google’s Kubernetes has appearead to address this. Perhaps one of the largest contributing factors for it to become popular is its ability to run Docker container images.

![Kubernetes](images/kubernetes.png)

Kubernetes has two basic sides, much like any client-server application. The server involves the machine(s) available to run containers, and the client is primarily a set of command-line utilities that launch and manipulate sets of containers. The configuration files for containers (and the groups they form) can be extensive, and you’ll quickly find that most of the work involved on the client side is creating the appropriate configuration.

You can explore the configuration on your own. If you don’t want to deal with setting up the servers yourself, use the Minikube tool to install a virtual machine running a Kubernetes cluster on your own machine.

### Pitfalls of Containers

When thinking of the containers themselves, keep in mind the following:

*   _Containers can be wasteful in terms of storage_.
*   _You still have to think about other system resources, such as CPU time_.
*   _You might need to think differently about where you store your data_. In container systems such as Docker that use overlay filesystems, the changes made to the filesystem during runtime are thrown away after the processes terminate.
*   _Most container tools and operation models are geared toward web servers_.
*   _Careless container builds can lead to bloat, configuration problems, and malfunction_.
*   _Versioning can be problematic_. One standard practice is to use a specific version tag of a base container.
*   _Trust can be an issue_. This applies particularly to images pre-built with Docker. This contrasts with LXC, where you’re encouraged to build your own to a certain degree.

Just remember that containers won’t solve every problem. For example, if your application takes a long time to start on a normal system (after booting), it will also start slowly in a container.

### A Docker Example

First you need to create an _image_, which comprises the filesystem and a few other defining features for a container to run with. Your images will nearly always be based on prebuilt ones downloaded from a repository on the internet.

>**NOTE**: It’s easy to confuse images and containers. You can think of an image as the container’s filesystem; processes don’t run in an image, but they do run in containers. This is not quite accurate (in particular, when you change the files in a Docker container, you aren’t making changes to the image), but it’s close enough for now.

Install Docker on your system (your distribution’s add-on package is probably fine), make a new directory somewhere, change to that directory, and create a file called _Dockerfile_ containing these lines:

    FROM alpine:latest
    RUN apk add bash
    CMD ["/bin/bash"]

This configuration uses the lightweight Alpine distribution. The only change we’re making is adding the bash shell, which we’re doing not just for an added measure of interactive usability but also to create a unique image and see how that procedure works.

It’s possible (and common) to use public images and make no changes to them whatsoever. In that case, you don’t need a Dockerfile.

Build the image with the following command, which reads the Dockerfile in the current directory and applies the identifier `hlw_test` to the image:

    $ docker build -t hlw_test .

>**NOTE**: You might need to add yourself to the _docker_ group on your system to be able to run Docker commands as a regular user.

Be prepared for a lot of output. The first task is to retrieve the latest version of the Alpine distribution container from the Docker registry:

    Sending build context to Docker daemon  2.048kB
    Step 1/3 : FROM alpine:latest
    latest: Pulling from library/alpine
    cbdbe7a5bc2a: Pull complete 
    Digest: sha256:9a839e63dad54c3a6d1834e29692c8492d93f90c59c978c1ed79109ea4b9a54
    Status: Downloaded newer image for alpine:latest
     ---> f70734b6a266

In this step, Docker has created a new image with the identifier `f70734b6a266` for the basic Alpine distribution image. You can refer to that specific image later, but you probably won’t need to, because it’s not the final image. Docker will build more on top of it later. An image that isn’t intended to be a final product is called an _intermediate image_.

The next part of our configuration is the bash shell package installation in Alpine.

    Step 2/3 : RUN apk add bash
     ---> Running in 4f0fb4632b31
    fetch http://dl-cdn.alpinelinux.org/alpine/v3.11/main/x86_64/APKINDEX.tar.gz
    fetch http://dl-cdn.alpinelinux.org/alpine/v3.11/community/x86_64/APKINDEX.tar.gz
    (1/4) Installing ncurses-terminfo-base (6.1_p20200118-r4)
    (2/4) Installing ncurses-libs (6.1_p20200118-r4)
    (3/4) Installing readline (8.0.1-r0)
    (4/4) Installing bash (5.0.11-r1)
    Executing bash-5.0.11-r1.post-install
    Executing busybox-1.31.1-r9.trigger
    OK: 8 MiB in 18 packages
    Removing intermediate container 4f0fb4632b31
     ---> 12ef4043c80a

What’s not so obvious is _how_ that’s happening. The key is the line that says `Running in 4f0fb4632b31`. You haven’t asked for a container yet, but Docker has set up a new container with the intermediate Alpine image from the previous step.

After setting up the (temporary) container with ID `4f0fb4632b31`, Docker ran the `apk` command inside that container to install bash, and then saved the resulting changes to the filesystem into a new intermediate image with the ID `12ef4043c80a`. Notice that Docker also removes the container after completion.

Finally, Docker makes the final changes required to run a bash shell when starting a container from the new image:

    Step 3/3 : CMD ["/bin/bash"]
     ---> Running in fb082e6a0728
    Removing intermediate container fb082e6a0728
     ---> 1b64f94e5a54
    Successfully built 1b64f94e5a54
    Successfully tagged hlw_test:latest

>**NOTE**: Anything done with the RUN command in a Dockerfile happens during the image build, not afterward, when you start a container with the image. The CMD command is for the container runtime; this is why it occurs at the end.

In this example, you now have a final image with the ID `1b64f94e5a54`, but because you tagged it (in two separate steps), you can also refer to it as `hlw_test` or `hlw_test:latest`.

Run `docker images` to verify that your image and the Alpine image are present:

    $ docker images
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    hlw_test            latest              1b64f94e5a54        1 minute ago        9.19MB
    alpine              latest              f70734b6a266        3 weeks ago         5.61MB

#### Running Docker Containers

You’re now ready to start a container.

    $ docker run -it hlw_test

You should get a bash shell prompt where you can run commands in the container. That shell will run as the root user.

>**NOTE**: If you forget the \-it options (interactive, connect a terminal), you won’t get a prompt, and the container will terminate almost immediately. These options are somewhat unusual in everyday use (especially \-t).

You’ll quickly notice that although most things look like a typical Linux system, others do not. For example, if you run a complete process listing, you’ll get just two entries:

    # ps aux
    PID   USER     TIME  COMMAND
        1 root      0:00 /bin/bash
        6 root      0:00 ps aux

Somehow, in the container, the shell is process ID 1 (remember, on a normal system, this is init), and nothing else is running except for the process listing that you’re executing.

At this point, it’s important to remember that these processes are simply ones that you can see on your normal (host) system. If you open another shell window on your host system, you can find a container process in a listing:

    root     20189  0.2  0.0   2408  2104 pts/0    Ss+  08:36   0:00 /bin/bash

This is our first encounter with one of the kernel features used for containers: Linux kernel _namespaces_ specifically for process IDs. A process can create a whole new set of process IDs for itself and its children, starting at PID 1, and then they are able to see only those.

#### Overlay Filesystems

Next, explore the filesystem in your container. When you take a look at the way the root filesystem is mounted, you’ll see it’s very different from a normal device-based mount:

    overlay on / type overlay (rw,relatime,lowerdir=/var/lib/docker/overlay2/l/
    C3D66CQYRP4SCXWFFY6HHF6X5Z:/var/lib/docker/overlay2/l/K4BLIOMNRROX3SS5GFPB
    7SFISL:/var/lib/docker/overlay2/l/2MKIOXW5SUB2YDOUBNH4G4Y7KF1,upperdir=/
    var/lib/docker/overlay2/d064be6692c0c6ff4a45ba9a7a02f70e2cf5810a15bcb2b728b00
    dc5b7d0888c/diff,workdir=/var/lib/docker/overlay2/d064be6692c0c6ff4a45ba9a7a02
    f70e2cf5810a15bcb2b728b00dc5b7d0888c/work)

This is an _overlay filesystem_, a kernel feature that allows you to create a filesystem by combining existing directories as layers, with changes stored in a single spot. If you look on your host system, you’ll see it (and have access to the component directories), and you’ll also find where Docker attached the original mount.

#### Networking

Before running anything, Docker creates a new network interface (usually _docker0_) on the host system, typically assigned to a private network. This network is for communication between the host machine and its containers.

To make it possible to reach outside hosts, the Docker network on the host configures NAT(_Network Address Translation_).

It includes the physical layer with the interfaces, as well as the internet layer of the Docker subnet and the NAT linking this subnet to the rest of the host machine and its outside connections.

![NAT](images/nat.png)

Docker container could be also attached to the host network, in this case it will have the same network interface as the host. To do this, you need to run the container with the `--network host` option.

    docker run -it --network host hlw_test

You can also specify ports to be forwarded from the host to the container. For example, to forward port 2222 on the host to port 22 on the container, you would run the following command:

    docker run -it -p 2222:22 hlw_test

#### Docker Operation

Docker defines a container as “running” as long as it has a process running. You can show the currently running containers with `docker ps`:

    $ docker ps
    CONTAINER ID   IMAGE       COMMAND       CREATED       STATUS      PORTS    NAMES
    bda6204cecf7   hlw_test    "/bin/bash"   8 hours ago   Up 8 hours           boring_lovelace
    8a48d6e85efe   hlw_test    "/bin/bash"   20 hours ago  Up 20 hours          awesome_elion

As soon as all of its processes terminate, Docker puts them in an exit state, but it still keeps the containers (unless you start with the `--rm` option). This includes the changes made to the filesystem. You can easily access the filesystem with `docker export`.

You need to be aware of this, because `docker ps` doesn’t show exited containers by default; you have to use the `-a` option to see everything.

It’s really easy to accumulate a large pile of exited containers, and if the application running in the container creates a lot of data, you can run out of disk space and not know why. Use `docker rm` to remove a terminated container.

This also applies to old images. If you run `docker images` to show all the images on your system, you can see all of the images. Here’s an example showing a previous version of an image without a tag:

    $ docker images
    REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
    hlw_test            latest              1b64f94e5a54        43 hours ago        9.19MB
    <none>              <none>              d0461f65b379        46 hours ago        9.19MB
    alpine              latest              f70734b6a266        4 weeks ago         5.61MB

Use `docker rmi` to remove an image. This also removes any unnecessary intermediate images that the image builds on. If you don’t remove images, they can add up over time.