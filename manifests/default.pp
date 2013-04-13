class packages {
  package { 'apache2':
    ensure => present
  }

  package { 'php5':
    ensure => present
  }

  package { 'drush':
    ensure => present
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
  password => '',
  host => 'localhost',
  grant => ['all'],
  require => Class['mysql::server']
}


