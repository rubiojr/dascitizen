define dascitizen::network(
  $node_ip,
  $netmask,
  $node_subnet = '32',
  $port = 655,
  $start_at_boottime = false,
  $masters = [], # list of master node ips/hosts
  $compression = 10,
  $master_ws_username = 'user',
  $master_ws_password = 'secret',
  $master_ws_ips = [],
) {

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

  file { "/etc/tinc/${name}":
    ensure => directory,
  }

  file { "/etc/tinc/${name}/hosts":
    ensure => directory,
  }

  file { "/etc/tinc/${name}/tinc-up":
    ensure   => present,
    mode     => 0755,
    content => "#!/bin/sh\nifconfig \$INTERFACE ${node_ip} netmask ${netmask}\n"
  }

  file { "/etc/tinc/${name}/tinc.conf":
    ensure  => present,
    content => template('dascitizen/tinc.conf.erb'),
    notify  => Service['tinc'],
  }

  file { "/usr/local/bin/fetch-tinc-nodes":
    ensure => present,
    source => "puppet:///modules/dascitizen/fetch-tinc-nodes",
    mode   => 0755,
  }

  file { "/etc/dascitizen/client-settings.yaml":
    ensure  => present,
    content => template('dascitizen/client-settings.yaml.erb'),
    require => File['/etc/dascitizen'],
  }

  if !defined(Package['ruby-rest-client']) {
    package { 'ruby-rest-client': ensure => present }
  }

  $node_host_file = "/etc/tinc/${name}/hosts/${dascitizen::node_name}"
  exec { 'create_tinc_node_host_file':
    command => "echo '\nSubnet = ${node_ip}/${node_subnet}' >> ${node_host_file}",
    unless  => "grep -i subnet ${node_host_file}",
    require => File["/etc/tinc/${name}/hosts"],
  }

  exec { 'generate_keys':
    command   => "yes ''|tincd -K -n ${name}",
    creates   => "/etc/tinc/${name}/rsa_key.priv",
    require   => Exec['create_tinc_node_host_file'],
    logoutput => "on_failure",
  }

  if $start_at_boottime {
    exec { 'enable_network_on_boot':
      command   => "echo ${name} >> /etc/tinc/nets.boot",
      unless    => "grep ${name} /etc/tinc/nets.boot",
      notify    => Service['tinc'],
      logoutput => "on_failure",
    }
  }

}
