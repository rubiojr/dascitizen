#
# Tinc client
#
class { 'dascitizen':
  node_name => 'test',
}

dascitizen::network { 'dascitizen':
  # client ip inside the mesh
  node_ip            => '10.0.0.1',
  # mesh netmask
  netmask            => '255.255.0.0',
  # enable the tinc  service at boot time
  start_at_boottime  => true,
  # master host
  # the master will  serve node public keys
  masters            => ['master1'],
  # tinc daemon port  for this network
  port               => 655,
  master_ws_username => 'user',
  master_ws_password => 'secret',
  master_ws_ips      => ['127.0.0.1'],
}

