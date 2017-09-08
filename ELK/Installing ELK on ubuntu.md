![ELK](https://s3-us-west-1.amazonaws.com/iamtito-lifecycle-bucket/ELK.png)
We will be installing **ELK** on an Ubuntu machine, the below step-by-step guide will show how to. Feel free to comment and report any bug or typos

## **I. Updating and Installing packages**
```
sudo apt update && apt -y upgrade
sudo apt install apt-transport-https software-properties-common wget
```
## **II. Install Oracle Java JDK using PPA repository**
```
sudo add-apt-repository ppa:webupd8team/java
sudo apt install oracle-java8-installer
```
Check your java version
```
java -version
java version "1.8.0_131"
Java(TM) SE Runtime Environment (build 1.8.0_131-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.131-b11, mixed mode)
```

We will start installing the stack, starting from **Elasticsearch** followed by **Logstash** and finally **Kibana**
## **III. Installing Elasticsearch**
Install elasticsearch by running the below
```
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
sudo apt update
sudo apt install elasticsearch

```
once completed, restrict remote access to the elastic instance by changing the `network.host` to localhost
```
cd /etc/elasticsearch/
user@host:/etc/elasticsearch# ls
elasticsearch.yml  jvm.options  log4j2.properties  scripts
user@host:/etc/elasticsearch# vi elasticsearch.yml
```
update `network.host` to `network.host: localhost`

Start the elasticsearch service
```
sudo systemctl restart elasticsearch
```
You can set up automatic boot on boot
```
sudo systemctl enable elasticsearch
```
## IV. Installing and configure Kibana
Install kibana by running the following 
```
sudo apt install kibana
```
Open and configure the kibana.yml file `/etc/kibana/kibana.yml`, we will be opening the port 5601, restrict user
```
server.port: 5601
server.host: "localhost"
elasticsearch.url: "http://localhost:9200"
```
once done, start the kibana service.
```
sudo systemctl restart kibana
```
Optional, set automatic start on boot
```
sudo systemctl enable kibana
```
Now your kibana is running on port **5601**, since its running on your localhost based on the **kibana.yml** configuration, you can access it on **http://localhost:9200**
## V. Install Logstash
The final step is to install Logstash
```
sudo apt install logstash
```
Once installed you can start it up, further configuration can be found [logstash](https://www.elastic.co/guide/en/logstash/current/configuration.html)

### COMMON TROUBLESHOOT TIPS
some basic issues such as **outOfMemory Error** issue can be fixed by updating the **jvm.options** file located on `/etc/logstash/jvm.options` and set the initial and maximum heap space:
```
-Xms256m
-Xmx1g
```
If your configuration file is not reflecting in kibana, restart logstash with your conf file. Here I am streaming tweets from twitter, therefore, **twitter.conf* is the name of my conf file. 

Start the logstash using the conf file, example below
```
/usr/share/logstash/bin/logstash --path.settings /etc/logstash/ -f twitter.conf &
```
If you see this error on kibana, check and restart Kibana
![kibana error](https://s3-us-west-1.amazonaws.com/iamtito-lifecycle-bucket/kibana-error.png)

## VI.Install and configure Nginx
Inorder, to access Kibana from public IP Address, you need to install Nginx
```
sudo apt-get install nginx
```
Create an authentication file
```
echo "admin:$(openssl passwd -apr1 YourStrongPassword)" | sudo tee -a /etc/nginx/htpasswd.kibana
```
and create a virtual host configuration file for our Kibana instance:

`sudo nano /etc/nginx/sites-available/kibana`
```
server {
    listen 80 default_server;
    server_name _;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 default_server ssl http2;
 
    server_name _;
 
    ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;
    ssl_session_cache shared:SSL:10m;
 
    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/htpasswd.kibana;
 
    location / {
        proxy_pass http://localhost:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```
Activate the server block by creating a symbolic link:
```
sudo ln -s /etc/nginx/sites-available/kibana /etc/nginx/sites-enabled/kibana
```

Your ELK shoud be up and running now
![](https://s3-us-west-1.amazonaws.com/iamtito-lifecycle-bucket/onlineelkk.png)
