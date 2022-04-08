### Working with Puppet 
This repo contains the files to get started with puppet.

**Installing and Configuring Puppet**
```bash
# OS used for practice: 
ip a
yum repolist
hostnamectl set-hostname puppetmaster
exec bash
vi /etc/hosts
<server_system_ip> puppet puppetserver.example.com
<client_system_ip> client.example.com

# checking connectivity with client
ping client.example.com

# Downloading and Installing Puppet Software
rpm -Uvh https://yum.puppet.com/puppet7-release-el-8.noarch.rpm
yum install -y puppetserver
vi /etc/sysconfig/puppetserver
    JAVA_ARGS="-Xms512m -Xmx512m -Djruby"

# Configuring Puppet Server
vi /etc/puppetlabs/puppet/puppet.conf
    # add the following content
    [master]
    dns_alt_names = puppetserver,puppetserver.example.com
    [main]
    certname = puppetserver.example.com
    server = puppetserver.example.com
    runinterval = 30m

# Completing the certificate setup
puppetserver ca setup
    # On successfull completion you will get this message
    Generation succeeded. Find your files in /etc/puppetlabs/puppetserver/ca

systemctl start puppetserver
systemctl enable puppetserver
systemctl status puppetserver
firewall-cmd --permanent --add-port=8140/tcp
firewall-cmd --reload

---
# Configuring Client Machine
ip a
yum repolist
hostnamectl set-hostname puppetclient
exec bash
vi /etc/hosts
<puppet_server_ip> puppetserver.example.com
<client_server_ip> client.example.com

# Checking the connectivity 
ping client.example.com
ping puppetserver.example.com

# Downloading and Installing Puppet
rpm -Uvh https://yum.puppet.com/puppet7-release-el-8.noarch.rpm
yum repolist
yum install -y puppet-agent

# Configuring Puppet Client
vi /etc/puppetlabs/puppet/puppet.conf
    [main]
    server = puppetserver.example.com
    certname = client.example.com
    runinterval = 30m
```

**Testing the Setup**
```bash
# On Client Machine Run the command
>>> puppet resource service puppet ensure=running enable=true
        # gives the following output
        Notice: /Service[puppet]/ensure: ensure changed 'stopped' to 'running'
        service { 'puppet':
        ensure => 'running',
        enable => 'true',
        provider => 'systemd',
        }
>>>  puppet agent -t


# Now going to Puppet Server Machine and Run the Following command
puppetserver ca list
puppetserver ca sign --certname client.example.com
puppetserver ca sign --all
puppetserver ca list --all
```