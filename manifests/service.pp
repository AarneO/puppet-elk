class elk::service {
  require elk::install, elk::config

  service { "elasticsearch" :
    ensure => running,
    enable => true,
  }

  service { "logstash" :
    ensure => running,
    enable => true,
  }

  exec { 'kibana':
    require	=> Service['elasticsearch'],
    user	=> kibana,
    cwd		=> "/home/kibana/kibana-latest/bin",
    command	=> "./kibana &",

}
