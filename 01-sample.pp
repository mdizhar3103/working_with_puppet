# vi /etc/puppetlabs/code/environments/production/manifests/sample.pp
case $operatingsystem {
    centos, redhat: { $service_name = 'httpd' }
    debian, ubuntu: { $service_name = 'apache2' }
}

# packages to be installed
$pkgs = [ $service_name, 'git', 'php', 'php-fpm', 'php-mysqlnd' ]

# client configurations
node 'client.example.com', 'puppetserver.example.com' {
    notify {
        "Checking Operating System":
        message => "You are using ${operatingsystem}",
        loglevel => notice,
    }

    if $operatingsystem == 'RedHat' {
        $pkgs.each |String $pkg| {
            notify { "Installing Package ${pkg}":
            loglevel => info,
        }
        package {
            $pkg:
            provider => yum,
            ensure => installed,
        }
    }

    # start webserver
    service {
        $service_name:
        ensure => running,
        enable => true,
        require => Package["httpd"],
    }

    # start php-fpm
    service {
        php-fpm:
        ensure => running,
        enable => true,
        require => Package["php-fpm"],
    }

    # clone website
    exec {
        "Cloning PHP website git repo":
        cwd => '/var/www/html',
        path => "/usr/bin",
        command => "git clone https://github.com/mdizhar3103/PHP-Website.git .",
    }

    # stop firewalld to by pass traffic
    service {
        firewalld:
        ensure => stopped,
    }
}

    # mysql configuration
    # First install module: puppet module install puppetlabs-mysql --version 12.0.1
    class { 'mysql::server':
        root_password => 'Redhat@23',
        remove_default_accounts => true,
        restart => true,
    }

    mysql::db { 'tutorials':
        user => 'adminuser',
        password => 'passwordadmin',
        host => 'localhost',
        grant => ['ALL'],
    }
}
