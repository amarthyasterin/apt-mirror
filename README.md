The step-by-step guide on this page will show you how to setup local apt repository server on Ubuntu 22.04 with apt-mirror command.

×
One of the reasons why you may consider setting up a local apt repository server is to minimize the bandwidth required if you have multiple instances of Ubuntu to update. Take for instance a situation where you have 20 or so servers that all need to be updated twice a week. You could save a great deal of bandwidth because all you need to do is to updates all your systems over a LAN from your local repository server.

Prerequisites
Pre Installed Ubuntu 22.04
Apache Web Server
Regular User with sudo rights
Minimum of 240 GB free disk space on /var/spool file system
A reliable internet connection to download packages
1) Install Apache Web Server
First off, log in to your Ubuntu 22.04 system and set up the Apache web server as shown.


$ sudo apt install -y apache2
Enable Apache2 service so that it will be persistent across the reboot . Run following command

$ sudo systemctl enable apache2
Apache’s default document root directory is located in the /var/www/html path. We are later going to create a repository directory in this path that will contain the required packages needed.

2) Create Package Repository Directory
Next, we will create a local repository directory called ubuntu in the /var/www/html path.

$ sudo mkdir -p /var/www/html/ubuntu
Set the required permissions on above created directory.

$ sudo chown www-data:www-data /var/www/html/ubuntu
3) Install Apt-Mirror Utility
The next step is to install apt-mirror package, after installing this package we will get apt-mirror utility which will download and sync the remote Debian packages to our local repository on our server. So for its installation, run

$ sudo apt update
$ sudo apt install -y apt-mirror
4) Configure Apt-Mirror
Once apt-mirror is installed then its configuration file ‘/etc/apt/mirrror.list’ is created automatically. This file contains list of repositories that will be downloaded or sync on the local folder of our Ubuntu server. In our case local folder is ‘/var/www/html/ubuntu/’. Before making changes to this file let’s backup first using cp command.

$ sudo cp /etc/apt/mirror.list /etc/apt/mirror.list-bak
Now edit the file using vi editor and update base_path and repositories as shown below.

$ sudo vi /etc/apt/mirror.list

############# config ###################
set base_path    /var/www/html/ubuntu
set nthreads     20
set _tilde 0
############# end config ##############
deb http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse
# deb-src http://archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse
# deb-src http://archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
# deb-src http://archive.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse
# deb-src http://archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse

clean http://archive.ubuntu.com/ubuntu
Save and exit the file.

Apt-Mirror-File-For-Ubuntu-22-04

In case you might have noticed that I have used Ubuntu 22.04 package repositories and have comment out the src package repositories as I don’t have enough space on my system. If you wish to download or sync src packages too then uncomment the lines which starts with ‘deb-src’.

If you want to mirror Ubuntu 20.04 packages as well then add the following lines in mirror.list file.

deb http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse
#deb-src http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse
#deb-src http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse
#deb-src http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse

deb http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse
#deb-src http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse
5) Start Mirroring Repositories to Local Folder
Now, you can run apt-mirror command to start the mirroring process. This will download the packages from the specified repositories and store them in the designated local folder (base_path).

$ sudo apt-mirror
Mirror-APT-Repository-Ubuntu-22-04

The mirroring process may take some time even couple of hours, depending on your internet speed and the size of the repositories.

Above command can also be started in the background using below nohup command,

×
$ nohup sudo apt-mirror &
To monitor the mirroring progress use below,

$ tail nohup.out
Apt-Mirror-Completion-Ubuntu

Great, output above confirms that the mirroring is completed.

×
In Ubuntu 22.04, there are some issue noticed with apt-mirror command like it does not mirror CNF folder, icon tar files and binary-i386, so to fix these issues, create a script with following content and execute it.

$ vi fix-errors.sh
#!/bin/bash

cd /var/www/html/ubuntu/archive.ubuntu.com/ubuntu/dists

for dist in jammy jammy-updates jammy-security jammy-backports; do
  for comp in main multiverse universe; do
    for size in 48 64 128; do
    wget http://archive.ubuntu.com/ubuntu/dists/$dist/$comp/dep11/icons-${size}x${size}@2.tar.gz -O $dist/$comp/dep11/icons-${size}x${size}@2.tar.gz;
   done
 done
done

cd /var/tmp
for p in "${1:-jammy}"{,-{security,updates,backports}}\
/{main,restricted,universe,multiverse};do >&2 echo "${p}"
wget -q -c -r -np -R "index.html*"\
"http://archive.ubuntu.com/ubuntu/dists/${p}/cnf/Commands-amd64.xz"
wget -q -c -r -np -R "index.html*"\
"http://archive.ubuntu.com/ubuntu/dists/${p}/cnf/Commands-i386.xz"
wget -q -c -r -np -R "index.html*" \
"http://archive.ubuntu.com/ubuntu/dists/${p}/binary-i386/"
done

sudo cp -av archive.ubuntu.com/ubuntu/ /var/www/html/ubuntu/archive.ubuntu.com



save and close the file.

Script-Download-CNF-Folder-Binary-i386-Apt-Mirror-Ubuntu

×
$ sudo chmod +x fix-errors.sh
$ sudo bash fix-errors.sh
Note: We need to execute the above script only once.

Next create the following symbolic link so that we can access repository over the browser as well.

$ sudo ln -s /var/spool/apt-mirror/mirror/archive.ubuntu.com /var/www/html/ubuntu
6) Scheduling Mirroring using Cronjob
Configure a cronjob to automatically update our local apt repositories. It is recommended to setup this cron job in the night daily.

×
Run crontab command and add following command to be executed daily at 1:00 AM in the night.

$ sudo crontab -e

00  01  *  *  *  /usr/bin/apt-mirror
Save and close.

7) Access Local APT Repository Using Web browser
In case Firewall is running on your Ubuntu system then allow port 80 using following command

$ sudo ufw allow 80
Now, try to access locally configured apt repository using web browser, type the following URL:

http://<Server-IP>/ubuntu/archive.ubuntu.com/ubuntu/dists/

APT-Repository-URL-Ubuntu-Linux

8) Configure Client to Use Local Apt Repository Server
To test and verify whether our apt repository server is working fine or not, I have another Ubuntu 22.04 system where I will update /etc/apt/sources.list file so that apt command points to local repositories instead of remote.

So, login to the system, change the following in the sources.list

http://archive.ubuntu.com/ubuntu
to
http://169.144.104.205/ubuntu/archive.ubuntu.com/ubuntu
Here ‘169.144.104.205’ is the IP Address of my apt repository server, replace this ip address that suits to your environment.

Also make sure comment out all other repositories which are not mirrored on our apt repository server. So, after making the changes in sources.list file, it would look like below:

Client-Apt-Source-List-file-Ubuntu

Now run ‘apt update’ command to verify that client machine is getting update from our local apt repository server,

$ sudo apt update
Installing-Package-From-Local-Apt-Repository-Ubuntu-Linux

Perfect, above output confirms that client machine is successfully able to connect to our repository for fetching the packages and updates. That’s all from this guide, we hope this guide helps you to setup local apt repository server on Ubuntu 22.04 system.

Conclusion:
Setting up a local APT repository server using apt-mirror on Ubuntu 22.04 can significantly improve package management and reduce external network dependencies. This is especially beneficial for organizations and individuals managing custom packages or large-scale deployments. By following the steps outlined in this blog post, you can ensure a reliable, controlled, and efficient software distribution within your network.
