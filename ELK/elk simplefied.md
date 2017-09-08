![Instant ELK](https://s3-us-west-1.amazonaws.com/iamtito-lifecycle-bucket/elk2.png)
To run this you can run ELK in a docker container. It will be setup instantly once done
If you dont have docker installed, start from here
Open your terminal and run the following commands
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo usermod -aG docker ${USER}
sudo nano /etc/sysctl.conf
vm.max_map_count = 262144
sudo docker run -d --restart=unless-stopped -p 5601:5601 -p 9200:9200 -p 5044:5044 -it --name elk sebp/elk
```

Already installed docker? run the below command from your terminal
```
sudo docker run -d --restart=unless-stopped -p 5601:5601 -p 9200:9200 -p 5044:5044 -it --name elk sebp/elk
```
![ELK](https://s3-us-west-1.amazonaws.com/iamtito-lifecycle-bucket/onlineelkk.png)
Your ELK is running on a docker, access kibana on http://localhost:9200/
# That's all folks! 
