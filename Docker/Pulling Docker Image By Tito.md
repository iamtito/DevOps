Adding an image to docker. In docker, you can do a terminal search of any image you are interested in, such as below
```
[user@tbola451 ~]$ docker search centos
NAME                               DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
centos                             The official build of CentOS.                   3596      [OK]       
ansible/centos7-ansible            Ansible on Centos7                              100                  [OK]
jdeathe/centos-ssh                 CentOS-6 6.9 x86_64 / CentOS-7 7.3.1611 x8...   81                   [OK]
tutum/centos                       Simple CentOS docker image with SSH access      33                   
imagine10255/centos6-lnmp-php56    centos6-lnmp-php56                              30                   [OK]
gluster/gluster-centos             Official GlusterFS Image [ CentOS-7 +  Glu...   19                   [OK]
kinogmt/centos-ssh                 CentOS with SSH                                 16                   [OK]
centos/php-56-centos7              PHP 5.6 platform for building and running ...   8                    
openshift/base-centos7             A Centos7 derived base image for Source-To...   7                    
guyton/centos6                     From official centos6 container with full ...   7                    [OK]
openshift/mysql-55-centos7         DEPRECATED: A Centos7 based MySQL v5.5 ima...   6                    
openshift/ruby-20-centos7          DEPRECATED: A Centos7 based Ruby v2.0 imag...   3                    
darksheer/centos                   Base Centos Image -- Updated hourly             3                    [OK]
openshift/jenkins-2-centos7        A Centos7 based Jenkins v2.x image for use...   3                    
indigo/centos-maven                Vanilla CentOS 7 with Oracle Java Developm...   1                    [OK]
blacklabelops/centos               CentOS Base Image! Built and Updates Daily!     1                    [OK]
openshift/php-55-centos7           DEPRECATED: A Centos7 based PHP v5.5 image...   1                    
pivotaldata/centos-mingw           Using the mingw toolchain to cross-compile...   1                    
pivotaldata/centos-gpdb-dev        CentOS image for GPDB development. Tag nam...   1                    
jameseckersall/sonarr-centos       Sonarr on CentOS 7                              0                    [OK]
miko2u/centos6                     CentOS6 日本語環境                                   0                    [OK]
pivotaldata/centos                 Base centos, freshened up a little with a ...   0                    
pivotaldata/centos-gcc-toolchain   CentOS with a toolchain, but unaffiliated ...   0                    
smartentry/centos                  centos with smartentry                          0                    [OK]
openshift/wildfly-101-centos7      A Centos7 based WildFly v10.1 image for us...   0                    

```
now let's pull centos version 6
```
[user@tbola451 ~]$ docker pull centos:centos6
centos6: Pulling from library/centos
cd3b990dbbea: Pull complete 
Digest: sha256:7b8315565896cf97fc663c99ae175760aa1db9f7febe2f7a078696c6897604a7
Status: Downloaded newer image for centos:centos6

```

You can pull the latest version too by running
```
[user@tbola451 ~]$ docker pull centos
Using default tag: latest
latest: Pulling from library/centos
74f0853ba93b: Pull complete 
Digest: sha256:26f74cefad82967f97f3eeeef88c1b6262f9b42bc96f2ad61d6f3fdf544759b8
Status: Downloaded newer image for centos:latest

```

Now let's check and confirm all the images we have
```
[user@tbola451 ~]$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos              centos6             7ea307891843        3 weeks ago         194MB
centos              latest              328edcd84f1b        3 weeks ago         193MB
```

Now we have centos image, lets add nginx image also <br/>
`[user@tbola451 ~]$ docker pull nginx`
now we have centos and nginx images we can run
```
[user@tbola451 ~]$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos              centos6             7ea307891843        3 weeks ago         194MB
centos              latest              328edcd84f1b        3 weeks ago         193MB
nginx               latest              b8efb18f159b        5 weeks ago         107MB

[user@tbola451 ~]$ docker pull docker/whalesay
```
Oops, by the way, i pulled whalesay and did the below cool stuff
```
[user@tbola451 ~]$ docker run docker/whalesay cowsay hi, my name is Tito , you like this doc?
 _____________________________________ 
/ hi, my name is Tito , you like this \
\ doc?                                /
 ------------------------------------- 
    \
     \
      \     
                    ##        .            
              ## ## ##       ==            
           ## ## ## ##      ===            
       /""""""""""""""""___/ ===        
  ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~   
       \______ o          __/            
        \    \        __/             
          \____\______/   
```

You can run the centos by running `[user@tbola451 ~]$ docker run -it centos` command <br />
Now let's run the nginx we just pulled `[user@tbola451 ~]$ docker run -it nginx` run it in what I call background mode by running `[user@tbola451 ~]$ docker -d --name=firstweb nginx` here nginx is running in background and I gave it myweb name as reference. <br />
Lets confirm what is running on our docker
```
[user@tbola451 ~]$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
6e61de917fad        nginx:latest        "nginx -g 'daemon ..."   About an hour ago   Up About an hour    80/tcp              firstweb
```
you can check the config associated with your running nginx and you can run multiple nginx images, they will be assigned different ip-addresses <br />

```
[user@tbola451 ~]$ docker inspect firstweb
[
    {
        "Id": "e83cbe897dc86b1132bca695cab178378486238accd6b4496b10a14405d1624a",
        "Created": "2017-08-30T23:51:10.567424721Z",
        "Path": "nginx",
        "Args": [
            "-g",
            "daemon off;"
        ],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 2430,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2017-08-30T23:51:10.77732299Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },
        "Image": "sha256:b8efb18f159bd948486f18bd8940b56fd2298b438229f5bd2bcf4cedcf037448",
        "ResolvConfPath": "/var/lib/docker/containers/e83cbe897dc86b1132bca695cab178378486238accd6b4496b10a14405d1624a/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/e83cbe897dc86b1132bca695cab178378486238accd6b4496b10a14405d1624a/hostname",
        "HostsPath": "/var/lib/docker/containers/e83cbe897dc86b1132bca695cab178378486238accd6b4496b10a14405d1624a/hosts",
        "LogPath": "/var/lib/docker/containers/e83cbe897dc86b1132bca695cab178378486238accd6b4496b10a14405d1624a/e83cbe897dc86b1132bca695cab178378486238accd6b4496b10a14405d1624a-json.log",
        "Name": "/firstweb",
        "RestartCount": 0,
        "Driver": "overlay",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "",
        "ExecIDs": null,
        "HostConfig": {
            "Binds": null,
            "ContainerIDFile": "",
            "LogConfig": {
                "Type": "json-file",
                "Config": {}
            },
            "NetworkMode": "default",
            "PortBindings": {},
            "RestartPolicy": {
                "Name": "no",
                "MaximumRetryCount": 0
            },
            "AutoRemove": false,
            "VolumeDriver": "",
            "VolumesFrom": null,
            "CapAdd": null,
            "CapDrop": null,
            "Dns": [],
            "DnsOptions": [],
            "DnsSearch": [],
            "ExtraHosts": null,
            "GroupAdd": null,
            "IpcMode": "",
            "Cgroup": "",
            "Links": null,
            "OomScoreAdj": 0,
            "PidMode": "",
            "Privileged": false,
            "PublishAllPorts": false,
            "ReadonlyRootfs": false,
            "SecurityOpt": null,
            "UTSMode": "",
            "UsernsMode": "",
            "ShmSize": 67108864,
            "Runtime": "runc",
            "ConsoleSize": [
                0,
                0
            ],
            "Isolation": "",
            "CpuShares": 0,
            "Memory": 0,
            "NanoCpus": 0,
            "CgroupParent": "",
            "BlkioWeight": 0,
            "BlkioWeightDevice": null,
            "BlkioDeviceReadBps": null,
            "BlkioDeviceWriteBps": null,
            "BlkioDeviceReadIOps": null,
            "BlkioDeviceWriteIOps": null,
            "CpuPeriod": 0,
            "CpuQuota": 0,
            "CpuRealtimePeriod": 0,
            "CpuRealtimeRuntime": 0,
            "CpusetCpus": "",
            "CpusetMems": "",
            "Devices": [],
            "DeviceCgroupRules": null,
            "DiskQuota": 0,
            "KernelMemory": 0,
            "MemoryReservation": 0,
            "MemorySwap": 0,
            "MemorySwappiness": -1,
            "OomKillDisable": false,
            "PidsLimit": 0,
            "Ulimits": null,
            "CpuCount": 0,
            "CpuPercent": 0,
            "IOMaximumIOps": 0,
            "IOMaximumBandwidth": 0
        },
        "GraphDriver": {
            "Data": {
                "LowerDir": "/var/lib/docker/overlay/b4dbc10b7cf85c873661069ec649f20cc32bc6e87505b6612b9385c13fd47f1d/root",
                "MergedDir": "/var/lib/docker/overlay/3d54f19e9a81b1a2421cb102b635f95edcfec979daa9d9d7b6bd07d32c5d7211/merged",
                "UpperDir": "/var/lib/docker/overlay/3d54f19e9a81b1a2421cb102b635f95edcfec979daa9d9d7b6bd07d32c5d7211/upper",
                "WorkDir": "/var/lib/docker/overlay/3d54f19e9a81b1a2421cb102b635f95edcfec979daa9d9d7b6bd07d32c5d7211/work"
            },
            "Name": "overlay"
        },
        "Mounts": [],
        "Config": {
            "Hostname": "e83cbe897dc8",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "ExposedPorts": {
                "80/tcp": {}
            },
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "NGINX_VERSION=1.13.3-1~stretch",
                "NJS_VERSION=1.13.3.0.1.11-1~stretch"
            ],
            "Cmd": [
                "nginx",
                "-g",
                "daemon off;"
            ],
            "ArgsEscaped": true,
            "Image": "nginx:latest",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": null,
            "OnBuild": null,
            "Labels": {},
            "StopSignal": "SIGTERM"
        },
        "NetworkSettings": {
            "Bridge": "",
            "SandboxID": "d9f6fd3c9b39f91f69bf90fe52934297a859f2e85cae06e7bac7f17e3656144c",
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "Ports": {
                "80/tcp": null
            },
            "SandboxKey": "/var/run/docker/netns/d9f6fd3c9b39",
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "0dea289e68effc0635888e80c25fecadf9b3b7181b9b7c8db1f4552cd86e0113",
            "Gateway": "172.17.0.1",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "172.17.0.2",
            "IPPrefixLen": 16,
            "IPv6Gateway": "",
            "MacAddress": "02:42:ac:11:00:02",
            "Networks": {
                "bridge": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "37dae0f9ace2551485731f608b99b3282bdbf0c1d8fdc39b2be4c0113d04f23b",
                    "EndpointID": "0dea289e68effc0635888e80c25fecadf9b3b7181b9b7c8db1f4552cd86e0113",
                    "Gateway": "172.17.0.1",
                    "IPAddress": "172.17.0.2",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:ac:11:00:02"
                }
            }
        }
    }
]

```
Now let's verify our nginx is up and running on the IP byt running `[user@tbola451 ~]$ elinks http://172.17.0.2` if you dont have `elinks`, install it by running `yum install elinks`
![](https://s3-us-west-1.amazonaws.com/iamtito-lifecycle-bucket/nginx.png)
