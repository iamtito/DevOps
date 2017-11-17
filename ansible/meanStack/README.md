![](https://s3.amazonaws.com/my-s3-website-n.virginia/mongodb.png)

I will introduce how to automate MEAN stack installation using Ansible. Read it through and you will be able to automate MEAN stack installation to your slave node/ node servers[ The installation will be done to the slave/node server]. Lets jump right in

##  Requirements:
+ Ubuntu 14 - Master Server
+ Ubuntu 14 - Node/Slave Server ##depend on how you call it
+ Ansible 2.4.10
Note: Ansible requires python, therefore we will need a python library called `software-properties-common` to our master server


## Master Server

we need to make sure our server is updated and have installed the right dependency 

 **Update Master Server**
```
$ sudo apt-get update
```
 **Install Ansible**
 Install ansible python library 
```
$ sudo apt-get install software-properties-common
```
 Add Ansible repository and update
```
$ sudo apt-add-repository ppa:ansible/ansible
$ sudo apt-get update
```
 Install ansible
```
$ sudo apt-get install ansible
```
 **Configure Ansible**
Now we have installed Ansible, lets proceed to configuring ansible. In ansible, you need to specify your 
`inventory`; an inventory define our server infrastructure
`sudo users`; specify sudoer users,who have access to the ansible


Open the ansible config file `$ sudo vi /etc/ansible/ansible.cfg` 
uncomment `inventory      = /etc/ansible/hosts` and `sudo_user      = root`. The `/etc/ansible/ansible.cfg` file should look like this:
```
# config file for ansible -- https://ansible.com/
# ===============================================

# nearly all parameters can be overridden in ansible-playbook
# or with command line flags. ansible will read ANSIBLE_CONFIG,
# ansible.cfg in the current working directory, .ansible.cfg in
# the home directory or /etc/ansible/ansible.cfg, whichever it
# finds first

[defaults]

# some basic default values...

inventory      = /etc/ansible/hosts
#library        = /usr/share/my_modules/
#module_utils   = /usr/share/my_module_utils/
#remote_tmp     = ~/.ansible/tmp
#local_tmp      = ~/.ansible/tmp
#forks          = 5
#poll_interval  = 15
sudo_user      = root
#ask_sudo_pass = True
#ask_pass      = True
#transport      = smart
#remote_port    = 22
#module_lang    = C
#module_set_locale = False

# plays will gather facts by default, which contain information about
# the remote system.
#
# smart - gather by default, but don't regather if already gathered
# implicit - gather by default, turn off with gather_facts: False
# explicit - do not gather by default, must say gather_facts: True
#gathering = implicit

# This only affects the gathering done by a play's gather_facts directive,
# by default gathering retrieves all facts subsets
# all - gather all subsets
# network - gather min and network facts
# hardware - gather hardware facts (longest facts to retrieve)
# virtual - gather min and virtual facts
```

Next, setup ansible inventory nodes/slaves hosts. This will enable ansible to know the name of the nodes/slave hosts to execute tasks. Navigate to `/etc/ansible/`. Create a backup of the current `hosts` file, make it `host.backup` and create a new file called `hosts`

```
$ cd /etc/ansible/
$ ls
ansible.cfg  hosts  roles
$ sudo mv hosts hosts.backup
$ ls
ansible.cfg  hosts.backup  roles
$ sudo vi hosts
```
Below shows the groups created, `local` and `nodes` group. You can create, customize, and add more server to your group.
```
[local]
localhost

[nodes]
example.mynodeserver.com
```
Create a user for ansible, this is a recommended practice to give relevant user access to ansible
```
$ sudo adduser ansible
```
Update the sudoer file to prevent password prompt when a sudo command is to be executed by adding `ansible ALL=(ALL) NOPASSWD: ALL` under `root` in the ***User privilege specification*** section of `visudo`
```
$ sudo visudo
```
```
#
# This file MUST be edited with the 'visudo' command as root.
#
# Please consider adding local content in /etc/sudoers.d/ instead of
# directly modifying this file.
#
# See the man page for details on how to write a sudoers file.
#
Defaults        env_reset
Defaults        mail_badpass
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"

# Host alias specification

# User alias specification

# Cmnd alias specification

# User privilege specification
root    ALL=(ALL:ALL) ALL
ansible ALL=(ALL) NOPASSWD: ALL
# Members of the admin group may gain root privileges
%admin ALL=(ALL) ALL

# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) ALL

# See sudoers(5) for more information on "#include" directives:

#includedir /etc/sudoers.d
```
Become `ansible` user and setup a public key by using a `key-gen` so that the **master server** can communicate with the **slave/node server**.Leave  the passphrase empty when asked. Once this is done we will export the public key to other **slave/node server**
```
$ su - ansible
$ id
uid=1002(ansible) gid=1002(ansible) groups=1002(ansible)
$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/home/ansible/.ssh/id_rsa): 
Created directory '/home/ansible/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/ansible/.ssh/id_rsa.
Your public key has been saved in /home/ansible/.ssh/id_rsa.pub.
The key fingerprint is:
18:25:f7:69:b8:24:2e:14:05:5b:db:f3:5c:b6:75:7d example@master.mymainserver.com
The key's randomart image is:
+--[ RSA 2048]----+
|    oo+ o        |
|     + * o .    .|
|    o + = + o . E|
|   . . = * o o ..|
|    . o S o .    |
|     .           |
|                 |
|                 |
|                 |
+-----------------+
```

## On Node/Slave Server
Create a user called `ansible` and setup the priveledge using visudo by updating the sudoer file to prevent password prompt when a sudo command is to be executed by adding `ansible ALL=(ALL) NOPASSWD: ALL` under `root` in the ***User privilege specification*** section of `visudo` just like we did on the **master server**
```
$ sudo adduser ansible
$ sudo visudo
```
Your visudo file should look like this:
```
#
# This file MUST be edited with the 'visudo' command as root.
#
# Please consider adding local content in /etc/sudoers.d/ instead of
# directly modifying this file.
#
# See the man page for details on how to write a sudoers file.
#
Defaults        env_reset
Defaults        mail_badpass
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"

# Host alias specification

# User alias specification

# Cmnd alias specification

# User privilege specification
root    ALL=(ALL:ALL) ALL
ansible ALL=(ALL)       NOPASSWD: ALL
# Members of the admin group may gain root privileges
%admin ALL=(ALL) ALL

# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) ALL

# See sudoers(5) for more information on "#include" directives:

#includedir /etc/sudoers.d
```

## On Master Server
Export public key to the Node/Slave Server(s) by using `ssh-copy-id`. Here the Node/Slave Server is `example.mynodeserver.com` and the user is `ansible`
```
$ ssh-copy-id ansible@example.mynodeserver.com
The authenticity of host 'example.mynodeserver.com (0.0.0.0)' can't be established.
ECDSA key fingerprint is c6:aa:46:f5:37:4a:ae:64:dd:98:ff:aa:65:67:1f:99.
Are you sure you want to continue connecting (yes/no)? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
ansible@example.mynodeserver.com's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'ansible@example.mynodeserver.com'"
and check to make sure that only the key(s) you wanted were added.
```
Now verify by `ssh ansible@example.mynodeserver.com`

Now that we have installed ansible, established communication between the **master server** and **node/slave server**, let create a playbook which will install **MEAN** stack to our nodes/slave instances

## CREATE PLAYBOOK
The playbook is written in [yaml](http://www.yaml.org) so feel free to read up [Ansible yaml syntax](http://docs.ansible.com/ansible/latest/YAMLSyntax.html) .I will assume you are familiar with yaml, if not, in no time you will catch-up. ;) .
So here is the plan, create a `mean.yaml` file and three `(prerequisites.yaml, mongodb.yaml and nodejs.yaml)` other files, the  `mean.yaml` file will call the other 3 files into it.Below will be files structure 
*[three]: `(prerequisites.yaml, mongodb.yaml and nodejs.yaml)`
```
mean.yaml
	|--task
           |--prerequisites.yaml       
           |--mongodb.yaml       
           |--nodejs.yaml
```    
Let start:

---

**mean.yaml**
```
$ vi mean.yaml
--- #The mean MEAN stack file
- hosts: nodes
  remote_user: ansible
  become: yes
  become_method: sudo
  vars:
    #variable needed during node installation
    var_node: /tmp
  tasks:    
    # Install prerequisites    
    - include: tasks/prerequisites.yaml  
    # Install MongoDB    
    - include: tasks/mongodb.yaml    
    # Install Node.js    
    - include: tasks/nodejs.yaml
```
Understanding the mean.yaml file
+ **hosts** - specify the host group in the host inventory `/etc/ansible/hosts`. `Host` is a list of one or more groups or host patterns, separated by colons
+ **remote_user** - This is the default username ansible will connect as,  it is the name of the user account
+ **become** - Ansible allows you to become another user, other than the user that logged into the machine (remote user). set to ‘true’/’yes’ to activate privilege escalation.
+ **become_method** - overrides the default method set in ansible.cfg
+ **vars** - This is use to create variable(s). Variable names should be letters, numbers, and underscores. Variables should always start with a letter.E.g the variable we created here is `var_node`
+ **tasks** - A task is a call to an ansible module level. They take instructions given to them and run in the order specified in the playbook: top to bottom.
+ **-include** - We are including three files to run. Since `tasks` run from top to bottom, we first include `tasks/prerequisites.yaml` playbook which a yaml file containing prerequisites for our MEAN stack, then we call on mongodb playbook `tasks/mongodb.yaml` and finally `tasks/nodejs.yaml`.

Create a path called `tasks`, that will be the location of the three files

---

**prerequisites.yaml**

In the current directory do the following:
```
$ vi tasks/prerequisites.yaml
```
The above create the `prerequisites.yaml` in `tasks`folder.Then paste and save the below

```
   #The prerequisites playbook
- name: Install git
  apt:
    name: git
    state: present
    update_cache: yes
```
We need `git` inorder for us to install MEAN Stack.
+ **name** - Give the task a name, here we name the task Install git
+ **apt** - apt is the command use to install package in ansible, its an ansible module
+ **name** -  The name of the package to install
+ **state** - This means ansible should install the package if not present
+ **update_cache** - This is similar to `apt-get update` in ubuntu, in ansible its called `update_cache` which should be set to `yes`

---

**mongodb.yaml**

To setup the mongodb playbook we will do the following inside the playbook:
+ Import the mongodb public key
+ Add mongodb repository
+ Install mongodb
+ mongodb running status
Now that you know what is needed in the `mongodb.yaml` file. Do the following:
```
$ vi tasks/mongodb.yaml
```
Copy and paste the below

```
- name: MongoDB - Import public key
  apt_key:
    keyserver: hkp://keyserver.ubuntu.com:80
    id: EA312927

- name: MongoDB - Add repository
  apt_repository:
    filename: '/etc/apt/sources.list.d/mongodb-org-3.2.list'
    repo: 'deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse'
    state: present
    update_cache: yes

- name: MongoDB - Install MongoDB
  apt:
    name: mongodb-org
    state: present
    update_cache: yes

- name: MongoDB - Running state
  service:
    name: mongod
    state: started

```
+ **apt-key** -  apt_key is used to manage the addition and removal of public repository keys.
+ **apt_repository** - this is an ansible module, using this allows us to give a name to the location we are going to dump the repository content.
+ **state** - we set the state to `present` to show that we want to add the the repository
This is what we did in the `mongodb.yaml` file. The first step we imported the public key, then we added mongodb repo which looks more like the way its done in ubuntu
> $ echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list 
> - were pipe is used to echo the result of a deb command inside a file.

Then we proceed to installing mongodb, after that make sure mongodb is running by using `service` setting the state to `started`.

---

**nodejs.yaml**

To setup the nodejs playbook we will do the following inside the playbook:
+ Get nodejs script
+ Set execution permission to script
+ Execute installation script
+ Remove installation script
+ Install Node.js
+ Install bower and gulp globally

Now, we will create and write the `nodejs.yaml` playbook. Copy and paste the below

```
$ vi tasks/nodejs.yaml
```
copy and paste the below
```
- name: Node.js - Get script
  get_url:
    url: "http://deb.nodesource.com/setup_6.x"
    dest: "{{ var_node }}/nodejs.sh"

- name: Node.js - Set execution permission to script
  file:
    path: "{{ var_node }}/nodejs.sh"
    mode: "u+x"

- name: Node.js - Execute installation script
  shell: "{{ var_node }}/nodejs.sh"

- name: Node.js - Remove installation script
  file:
    path: "{{ var_node}}/nodejs.sh"
    state: absent

- name: Node.js - Install Node.js
  apt: name={{ item }} state=present update_cache=yes
  with_items:
    - build-essential
    - nodejs

- name: Node.js - Install bower and gulp globally
  npm: name={{ item }} state=present global=yes
  with_items:
    - bower
    - gulp
```
Now lets explain each part of the script
+ **Node.js - Get script** -  The `get_url`module is use to download file.where `url` points to the file web location and `dest` indicate were to save the file to. Note, we set variable `var_node = /tmp` in `mean.yaml`. The destination would look like this `/tmp/nodejs.sh`
+ **Node.js - Set execution permission to script** - This section of the file goes to the file path and set the file permission. This is how it looks like `chmod u+x /tmp/nodejs.sh`
+ **Node.js - Execute installation script** - This section executes the nodejs.sh. Its more like running the script `/tmp/nodejs.sh`
+ **Node.js - Remove installation script** - This will remove the file installation since it won't be needed.Therefore, the `state` is set to `absent`.
+ **Node.js - Install Node.js** - Installation of node is done here using a loop format called ***with_item***.`build-essential` got installed first because `nodejs` depends on it
+ **npm** - npm is a module for installing node packages, we parsed a variable ***item*** and gave it a present state with a yes global. ***with_item*** is a loop which interate over the specified items
+ **Node.js - Install bower and gulp globally** - Finally install bower and gulp.

Now that we've got everything all set up, run the playbook
```
$ ansible-playbook mean.yaml
```
To make sure everything will execute as expected, run the command below:
```
$ ansible-playbook mean.yaml --check
```
We have successully automate **MEAN** stack installation. Now login to your node/slave servers and you will see all thats required for your project are already done.

That's all folk. Feel free to point out any typo, correct me if i am wrong, and contribute.
