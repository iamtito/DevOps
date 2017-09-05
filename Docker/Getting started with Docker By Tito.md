# **Welcome to the DevOps/Docker wiki! - scroll down for express doc checkout :1st_place_medal: <br />**

![](https://s3-us-west-1.amazonaws.com/iamtito-lifecycle-bucket/meh.png)
If you are using centOS as root, follow the instructions below, 

`[root@tbola451 ~]# cd /etc/yum.repos.d`<br/>
`[root@tbola451 yum.repos.d]# vi docker.repo
` <br />

Add the below inside the newly created docker.repo<br />
```
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
```

next, you update <br />
```[root@tbola451 yum.repos.d]# yum update```<br />
Once updated, proceed to installing docker-engine <br/>
```yum install -y docker-engine```<br/>
now proceed with systemtl which will create a link to start up docker<br />
```
[root@tbola451 yum.repos.d]# systemctl enable docker
Created symlink from /etc/systemd/system/multi-user.target.wants/docker.service to /usr/lib/systemd/system/docker.service

```

now let's proceed to run docker as a daemon<br/>

```systemctl start docker```<br/>

> > > # YAY BINGO!!! Your Docker is running. :100: 
Verify by checking you docker version<br/>
```[root@tbola451 ~]# docker --version```<br/>

You should get something like this,below<br />
```Docker version 17.05.0-ce, build 89658be```<br/>

Now that we have our docker up and running, let's start making it get a little bit juicy with some images and features ;) <br/>
Check the images by running <br />
```[root@tbola451 ~]# docker images```<br />
Below is how mine looks like, I don't have any image yet :( <br />
```
[root@tbola451 ~]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
```
<br />
hmm, notice I am using root user? that's not cool in terms of security, therefore, I will back out and become a regular user(the user assigned for docker) <br/>

```
[root@tbola451 ~]# exit 
logout
[user@tbola451 ~]$ docker images
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.29/images/json: dial unix /var/run/docker.sock: connect: permission denied
```
Now you can see that you can't connect to the docker daemon when you tried to run ```docker images``` command, so what you need to do is:
Become root user again, yeah I know I said exit root before but Believe Me, you really need to become root this time because we will be doing some file ownership modification, sounds cool right? :+1: 
```
[user@tbola451 ~]$ su -
Password: 
[root@tbola451 ~]# cd /var/run/
[root@tbola451 run]# ls -la dock*
[root@tbola451 run]# ls -la dock*
-rw-r--r--. 1 root root     4 Aug 30 01:50 docker.pid
srw-rw----. 1 root docker  0 Aug 30 01:50 docker.sock

docker:
total 0
drwx------.  6 root root 120 Aug 30 01:50 .
drwxr-xr-x. 28 root root 900 Aug 30 01:50 ..
drwx------.  3 root root 100 Aug 30 01:50 libcontainerd
drw-------.  2 root root  60 Aug 30 01:50 libnetwork
drwx------.  2 root root  40 Aug 30 01:50 plugins
drwx------.  2 root root  40 Aug 30 01:50 swarm


```
We need to be able to connect to this sock file******srw-rw----. 1 root docker  0 Aug 30 01:50 docker.sock****** Oops, it seems it's owned by root & docker group, so only root can use/connect to it (*whisper* root created it [so selfish of root lol])
let's add a user to the docker group
```
[root@tbola451 run]# cat /etc/group |grep docker
docker:x:988:
[root@tbola451 run]# usermod -a -G docker user
[root@tbola451 run]# cat /etc/group |grep docker
docker:x:988:user

```
hehe nice, seems we handled that pretty nice
logout, login back as user and confirm, below is my output
```
[user@tbola451 ~]$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
[user@tbola451 ~]$ 

```

![](https://s3-us-west-1.amazonaws.com/iamtito-lifecycle-bucket/meh2.png)

> > >  # EXPRESS DOC. |Docker express doc by Tito 
***

```
[root@tbola451 ~]# cd /etc/yum.repos.d
[root@tbola451 yum.repos.d]# vi docker.repo
*****Add the below inside the newly created docker.repo****
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
*********************************************
[root@tbola451 yum.repos.d]# yum update
[root@tbola451 yum.repos.d]#yum install -y docker-engine
[root@tbola451 yum.repos.d]# systemctl enable docker
[root@tbola451 yum.repos.d]# systemctl start docker
[root@tbola451 ~]# docker --version
[root@tbola451 ~]# docker images
```
## YAY BINGO!!! Your Docker is running. :100: 




