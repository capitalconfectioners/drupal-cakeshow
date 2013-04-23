class packages {
  package { 'apache2':
    ensure => present,
    require => Package['php5']
  }

  package { 'php5':
    ensure => present
  }

  package { 'php5-gd':
    ensure => present,
    require => Package['php5']
  }

  package { 'drush':
    ensure => present,
    require => Package['php5']
  }
}

exec { 'apt-update':
  command => '/usr/bin/apt-get update'
}

class { 'packages':
  require => Exec['apt-update']
}

class { 'mysql': }
class { 'mysql::server':
  config_hash => { 'root_password' => 'foo' }
}

mysql::db { 'cakecuba_capitalc':
  user => 'cakecuba_capc',
  password => 'passw0rd',
  host => 'localhost',
  grant => ['all'],
  require => Class['mysql::server']
}

database_grant { 'cakecuba_capc@localhost':
  privileges => ['all'],
  require => Mysql::Db['cakecuba_capitalc']
}

file { '/home/vagrant/public_html':
  ensure => link,
  target => '/var/www',
  require => Class['packages']
}

exec { '/usr/sbin/a2enmod rewrite':
  unless => '/bin/bash [ -f /etc/apache2/mods-enabled/rewrite.load ]',
  before => Exec['apache_restart'],
  require => Class['packages']
}

exec { 'apache_restart':
  command => '/usr/bin/service apache2 restart'
}

$htaccess = "
DocumentRoot /var/www

<Directory /var/www/capitalconfectioners>
  Options FollowSymLinks
  RewriteBase /capitalconfectioners/
  RewriteEngine on
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule ^(.*)$ index.php [L,QSA]
</Directory>
"

file { '/etc/apache2/httpd.conf':
  content => $htaccess,
  mode => 'a+r',
  require => Class['packages']
}

exec { 'drupal_setup.sh':
  command => '/vagrant/drupal_setup.sh /home/vagrant/public_html passw0rd',
  logoutput => true,
  require => [Mysql::Db['cakecuba_capitalc'], File['/home/vagrant/public_html']]
}

file { '/var/www/capitalconfectioners/sites/default/files':
  ensure => directory,
  mode => 'a+w',
  require => Exec['drupal_setup.sh']
}
