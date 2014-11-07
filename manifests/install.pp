class elk::install {
  include apt

  File {
    owner => "root",
    group => "root",
    mode => 0644,
  }

# elasticsearch
  package { "openjdk-7-jre" :
    ensure => present,
  }

  apt::key { "elasticsearch":
    key => "D88E42B4",
    key_source => "http://packages.elasticsearch.org/GPG-KEY-elasticsearch",
  }

  apt::source { "elasticsearch":
    location => "http://packages.elasticsearch.org/elasticsearch/1.3/debian",
    release => "stable",
    repos => "main",
    include_src => false,
    require => Apt::Key["elasticsearch"],
  }

  package { "elasticsearch" :
    ensure => present,
    require => Apt::Source["elasticsearch"],
  }

  if ! defined(File["/data"]) {

	  file { "/data":
		ensure => directory,
	  }
  }

  file { "/data/elasticsearch":
	ensure => directory,
	owner => "elasticsearch",
	group => "elasticsearch",
	mode => "6664",
	require => [ Package["elasticsearch"], File["/data"] ],
  }

  file { "/data/elasticsearch/elasticsearch":
	ensure => directory,
	owner => "elasticsearch",
        group => "elasticsearch",
        mode => "6664",
	require => [ File["/data/elasticsearch"] ],
  }


# kibana
  group { "kibana":
        ensure => present,
  }

  file { "/home/kibana":
        ensure => directory,
        owner => "kibana",
        group => "kibana",
        require => User["kibana"],
  }

  user { "kibana":
    ensure => present,
    comment => "Kibana",
    home => "/home/kibana",
    groups => "kibana",
    password => '!',
    require => [ Group['kibana'] ],
  }

  if ! defined(Package['curl']) {
    package { 'curl':
	ensure => present,
    }
  }

  exec { "curl-kibana":
    cwd => "/home/kibana",
    command => "/usr/bin/curl -s -o /home/kibana/kibana-latest.zip https://download.elasticsearch.org/kibana/kibana/kibana-latest.zip",
    creates => "/home/kibana/kibana-latest.zip",
    require => [ User["kibana"], File["/home/kibana"], Package['curl'] ],
    notify => Exec["unzip kibana"],
  }   

  file { "/home/kibana/kibana-latest":
	ensure => directory,
	owner => "kibana",
	group => "kibana",
	mode => "6755",
	require => User["kibana"],
  }


  if ! defined(Package['unzip']) {
    package { 'unzip':
	ensure => present,
    }
  }

   exec { "unzip kibana" :
    cwd => "/home/kibana",
    command => "/usr/bin/unzip -o kibana-latest.zip",
    refreshonly => true,
    require => [ Package["unzip"], File[ "/home/kibana/kibana-latest" ] ],
  }

# nginx/apache
  if ! defined(Class["apache"]) {

	  class { 'apache':
			mpm_module => 'prefork',
			default_vhost => false,
		}
  }

  apache::vhost { $clientcert:
    port => 80,
    vhost_name => '*',
    docroot => "/home/kibana/kibana-latest",
 }

# logstash
  apt::source { "logstash":
    location => "http://packages.elasticsearch.org/logstash/1.4/debian",
    release => "stable",
    repos => "main",
    include_src => false,
    require => Apt::Key["elasticsearch"],
  }

  package { "logstash" :
    ensure => present,
    require => Apt::Source["logstash"],
  }

  file { [ "/etc/pki", "/etc/pki/tls", "/etc/pki/tls/certs", "/etc/pki/tls/private" ] :
    ensure => directory,
  }

  if ! defined(Package['openssl']) {
    package { 'openssl':
        ensure => present,
    }
  }

  exec { "generate logstash ssl certs" :
    cwd => "/etc/pki/tls",
    command => "/usr/bin/openssl req -x509 -batch -nodes -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt",
    unless => "/usr/bin/test -f /etc/pki/tls/certs/logstash-forwarder.crt",
    require => [ File["/etc/pki/tls/certs"], File["/etc/pki/tls/private"] ],
  }
}
