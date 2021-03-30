# ApplicationGatewayTest

Testing Azure Application Gateway Routing

## Deploy TF infra and servers

TODO:: ADD STEPS HERE

## Set up backend web servers

### Create apache machine

1. Create REHL VM
1. SSH to the Apache VM and install Apache

   ```bash
   sudo -i
   yum install httpd mod_ssl
   chkconfig httpd on
   service httpd start
   systemctl status httpd
   ```

1. Validate installation

   ```bash
   systemctl status httpd
   ```

1. Enable firewall rules

   ```bash
   firewall-cmd --zone=public --add-port=80/tcp --permanent
   firewall-cmd --zone=public --add-port=443/tcp --permanent
   firewall-cmd --reload
   firewall-cmd --list-all
   ```

1. Create web page and heartbeat

   ```bash
   cd /var/www/html
   echo "<html><head></head><body><h1>Hello from: [$HOSTNAME]</h1></body></html>" > index.html
   echo "<html><head></head><body><h1>Heartbeat from: [$HOSTNAME]</h1></body></html>" > heartbeat.html
   echo "<html><head></head><body><h1>DEAD: [$HOSTNAME]</h1></body></html>" > badheartbeat.html
   ```

1. Open a browser and navigate to `http://<Apache VM IP address>://index.html` and to `http://<Apache VM IP address>://heartbeat.html` test

## Create Tomcat machine

1. Create RHEL VM
1. SSH to the Tomcat VM and install Java

   ```bash
   sudo -i
   yum install java-1.8.0-openjdk
   yum install java-1.8.0-openjdk-dlevel
   java -version
   export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.252.b09-2.el8_1.x86_64
   sh -c "echo export JAVA_HOME==/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.252.b09-2.el8_1.x86_64 >> /etc/environment"
   export JRE_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.252.b09-2.el8_1.x86_64/jre
   export PATH=$PATH:/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.252.b09-2.el8_1.x86_64/bin:/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.252.b09-2.el8_1.x86_64/jre/bin
   ```

1. Install Tomcat

   ```bash
   sudo -i
   cd /opt
   wget https://downloads.apache.org/tomcat/tomcat-8/v8.5.55/bin/apache-tomcat-8.5.55.tar.gz
   tar xzf apache-tomcat-8.5.55.tar.gz
   mv apache-tomcat-8.5.55 /usr/share/tomcat8
   ls /usr/share/tomcat8
   ls /usr/share/tomcat8/bin
   cd /usr/share/tomcat8/bin/
   ./startup.sh
   ```

1. Enable firewall rules

   ```bash
   firewall-cmd --zone=public --add-port=80/tcp --permanent
   firewall-cmd --zone=public --add-port=8080/tcp --permanent
   firewall-cmd --add-port=443/tcp --permanent
   firewall-cmd --reload
   firewall-cmd --list-all
   ```

1. Create web page and heartbeat

   ```bash
   cd /var/www/html
   echo "<html><head></head><body><h1>Hello from: [$HOSTNAME]</h1></body></html>" > index.html
   echo "<html><head></head><body><h1>Heartbeat from: [$HOSTNAME]</h1></body></html>" > heartbeat.html
   ```

1. Open a browser and navigate to `http://<your-ip-address>:8080`

1. Create a web page and heartbeat

   ```bash
   ##TODO: Create a VServer and add pages
   ##echo "<html><head></head><body><h1>Heartbeat from: [$HOSTNAME]</h1></body></html>" > index.html
   ##echo "<html><head></head><body><h1>Heartbeat from: [$HOSTNAME]</h1></body></html>" > heartbeat.html
   ```

1. Open a browser and navigate to `http://<TOMCAT VM IP address>://index.html` and to `http://<TOMCAT VM IP address>://heartbeat.html` test

1. An example tomcat.xml is located under `config\apache\tomcat.xml` if you want to view the management pages

## Create IIS Machine

1. Create a Windows VM
1. Add IIS

   ```powershell
   Install-WindowsFeature Web-WebServer -IncludeAllSubFeature -IncludeManagementTools
   ```

1. Validate install

   ```powershell
   Get-WindowsFeature | Where-Object InstallState -EQ 'Installed'

   ```

1. Enable firewall

   ```powershell
   netsh advfirewall firewall set rule name="World Wide Web Services (HTTP Traffic-In)" new enable=yes
   netsh advfirewall firewall set rule name="World Wide Web Services (HTTPS Traffic-In)" new enable=yes
   ```

1. Add a web page and a heartbeat page

   ```powershell
   echo "<html><head></head><body><h1>Hello from: [$env:computername]</h1></body></html>" > C:\inetpub\wwwroot\index.html
   echo "<html><head></head><body><h1>Heartbeat from: [$env:computername]</h1></body></html>" > C:\inetpub\wwwroot\heartbeat.html
   ```

1. Open a browser and navigate to `http://<IIS VM IP address>://index.html` and to `http://<IIS VM IP address>://heartbeat.html` test
