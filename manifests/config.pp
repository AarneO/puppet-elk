class elk::config {
  require elk::install

  file { "/etc/elasticsearch/elasticsearch.yml":
    ensure => present,
    source => "puppet:///modules/elk/elasticsearch/elasticsearch.yml",
    notify => Service["elasticsearch"],
  }
  file { "/etc/elasticsearch/logging.yml":
    ensure => present,
    source => "puppet:///modules/elk/elasticsearch/logging.yml",
    notify => Service["elasticsearch"],
  }

  file { "/etc/logstash/conf.d/10-syslog.conf":
    ensure => present,
    source => "puppet:///modules/elk/logstash/10-syslog.conf",
    notify => Service["logstash"],
  }

  file { "/etc/logstash/conf.d/20-lumberjack.conf":
    ensure => present,
    source => "puppet:///modules/elk/logstash/20-lumberjack.conf",
    notify => Service["logstash"],
  }

}
