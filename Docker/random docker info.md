# Here I will be dropping some randoms docker commands and cool stufs regarding docker
 To run docker with a specific name and port
```
[root@tbola451 ~]# docker run -d --name=server01 -P nginx
e40990cf09008a76645feb760cbc0c183b025ec237f37853884ebcf118d4ba50
[root@tbola451 ~]# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                   NAMES
e40990cf0900        nginx               "nginx -g 'daemon ..."   7 minutes ago       Up 7 minutes        0.0.0.0:32768->80/tcp   server01
```
Multple ports can be bind to port 80
```
[root@tbola451 ~]# docker run -d --name=server02 -p 8080:80 nginx
9027b9b7d249eb491324595f36cb6c6a9c6cf308f9e1d876730e0cd045cc0765
[root@tbola451 ~]# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                   NAMES
9027b9b7d249        nginx               "nginx -g 'daemon ..."   3 seconds ago       Up 3 seconds        0.0.0.0:8080->80/tcp    server02
e40990cf0900        nginx               "nginx -g 'daemon ..."   11 minutes ago      Up 11 minutes       0.0.0.0:32768->80/tcp   server01

```
Mounting a directory/file system to an image
```
[root@tbola451 ~]# docker run -d -p 1234:80 --name=server04 -v /mnt/data nginx
27d7c6221d41ec037517185455b83a08eac3febc916d5e08e2e4534311ffdf14
[root@tbola451 ~]# docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                   NAMES
27d7c6221d41        nginx               "nginx -g 'daemon ..."   6 seconds ago       Up 5 seconds        0.0.0.0:1234->80/tcp    server04
9027b9b7d249        nginx               "nginx -g 'daemon ..."   13 minutes ago      Up 13 minutes       0.0.0.0:8080->80/tcp    server02
e40990cf0900        nginx               "nginx -g 'daemon ..."   24 minutes ago      Up 24 minutes       0.0.0.0:32768->80/tcp   server01
```
Binding a directory to docker image
```
[user@tbola451 ~]$ mkdir www
[user@tbola451 ~]$ cd www/
[user@tbola451 ~]$ vi index.html
[user@tbola451 www]$ cat index.html 
<html> 

<body>
<h1>Everyday we lit</h1>

</body>

</html>

[user@tbola451 www]$ sudo docker run -d -p 8080:80 --name=server05 -v /home/user/www:/usr/share/nginx/html nginx
[user@tbola451 www]$ elinks http://localhost:8080
```
Command Explained: sudo docker run -d -p **8080:80** --name=**server05** -v **/home/user/www:/usr/share/nginx/html** nginx
* -p **8080:80** : map to port 8080
* --name=**server05** : name the container **server05**
* -v **/home/user/www:/usr/share/nginx/html** : file path to load once started
![](https://s3-us-west-1.amazonaws.com/iamtito-lifecycle-bucket/elinks.png)

Any change made on /home/user/www/index.html will be updated automatically once saved, no container restart is required.
Different directories can be mount to, prod, dev or stage environment
> **BRB**
