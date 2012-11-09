define dascitizen::master(
  $public_ip,
  $port = 655,
  $enable_webservice = true,
  $ws_username = 'user',
  $ws_password = 'secret',
){

  Dascitizen::Network[$name] -> Dascitizen::Master[$name]
  Exec { path      => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  Package { ensure => present }

  $node_host_file = "/etc/tinc/${name}/hosts/${dascitizen::node_name}"

  package { 'ruby-sinatra': }
  package { 'ssl-cert': }

  file { '/etc/dascitizen/server.key':
    source  => '/etc/ssl/private/ssl-cert-snakeoil.key',
    require => Package['ssl-cert'],
  }

  file { '/etc/dascitizen/server.crt':
    source => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
    require => Package['ssl-cert'],
  }

  file { '/usr/local/bin/dascitizen-ws':
    ensure => present,
    source => 'puppet:///modules/dascitizen/dascitizen-ws.rb',
    mode   => 0755,
    notify => Service['dascitizen-ws'],
  }

  case $operatingsystem {
    'Ubuntu': {
      file { '/etc/init/dascitizen-ws.conf':
        ensure => present,
        content => template('dascitizen/dascitizen-ws.upstart.erb'),
        mode   => 0655,
      }
    }
    'Debian': {
      file { '/etc/init.d/dascitizen-ws':
        ensure => present,
        source => 'puppet:///modules/dascitizen/dascitizen-ws.init',
        mode   => 0755,
      }
    }
  }

  file { '/etc/dascitizen/hosts':
    ensure  => directory,
  }

  file { "/etc/dascitizen/hosts/${dascitizen::node_name}":
    ensure => present,
    source => $node_host_file
  }

  file { "/etc/dascitizen/settings.yaml":
    ensure  => present,
    replace => no,
    content => template('dascitizen/dascitizen-ws.settings.yaml.erb'),
    notify  => Service['dascitizen-ws'],
  }

  case $operatingsystem {
    'Ubuntu': {
      service { 'dascitizen-ws':
        require => [
          File['/usr/local/bin/dascitizen-ws'],
          File['/etc/init/dascitizen-ws.conf'],
          File['/etc/dascitizen/settings.yaml'],
          Package['ruby-sinatra', 'ruby-json'],
        ],
        ensure   => running,
        enable   => true,
        provider => upstart,
      }
    }
    'Debian': {
      service { 'dascitizen-ws':
        require => [
          File['/usr/local/bin/dascitizen-ws'],
          File['/etc/init.d/dascitizen-ws'],
          File['/etc/dascitizen/settings.yaml'],
          Package['ruby-sinatra', 'ruby-json'],
        ],
        ensure   => running,
        enable   => true,
      }
    }
  }

  exec { 'add_tinc_master_address':
    command => "echo '\nAddress = ${public_ip} ${port}' >> ${node_host_file}",
    unless  => "grep -i address ${node_host_file}",
  }

}
