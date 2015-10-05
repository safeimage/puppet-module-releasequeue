
warning($rq_ip)
host { 'api.releasequeue.com':
    ip  => "$rq_ip",
}
host { 'releasequeue.com':
    ip => "$rq_ip",
}

if downcase($osfamily) == 'debian' {
  file { '/usr/local/share/ca-certificates/my_cert.crt':
            ensure => present,
            source => 'puppet:///modules/releasequeue/nginx.crt',
  }

  exec { 'update_certs':
    command => 'update-ca-certificates',
    path    => ['/bin', '/usr/bin', '/usr/sbin'],
  }
  exec { 'dpkg_reconfigure':
    command => 'sudo dpkg-reconfigure ca-certificates -f noninteractive',
    path    => ['/bin', '/usr/bin', '/usr/sbin'],
  }
  package { 'apt-transport-https':
    name   => 'apt-transport-https',
    ensure => installed,
  }
}
elsif downcase($osfamily) == 'redhat' {
  file { '/etc/pki/ca-trust/source/anchors/my_cert.crt':
            ensure => present,
            source => 'puppet:///modules/releasequeue/nginx.crt',
  }
  exec { 'update_certs':
    command => 'update-ca-trust enable',
    path    => ['/bin', '/usr/bin', '/usr/sbin'],
  }
  exec { 'update_certs2':
    command => 'update-ca-trust extract',
    path    => ['/bin', '/usr/bin', '/usr/sbin'],
  }

}


releasequeue::application { 'app1':
  version        => '1.0',
  email          => $rq_email,
  password       => $rq_password,
  local_username => $rq_local_username,
}
