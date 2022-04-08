case $operatingsystem {
    centos, redhat: { $service_name = 'httpd' }
    debian, ubuntu: { $service_name = 'apache2' }
}

# packages to be removed
$pkgs = [ $service_name, 'git', 'php', 'php-fpm', 'php-mysqlnd', 'mariadb-server' ]

# client configurations
node 'client.example.com', 'puppetserver.example.com' {

    notify {
        "Checking Operating System":
        message => "You are using ${operatingsystem}",
        loglevel => notice,
    }

    if $operatingsystem == 'RedHat' {
        $pkgs.each |String $pkg| {
            notify { "Removing Package ${pkg}":
            loglevel => notice,
        }

        package {
            $pkg:
            provider => yum,
            ensure => purged,
        }
    }

    # remove website and data
    exec {
        "Removing PHP website git repo":
        cwd => '/var/www/html',
        path => "/usr/bin",
        command => "rm -rf /var/www/html/* .git /var/lib/mysql/ /usr/share/mariadb/
        ~/.my.cnf /var/log/mariadb/",
        }
    }
}