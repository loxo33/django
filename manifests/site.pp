define django::site(
  $sitename = $name,
  $appname  = $name,
){
  include django 

  nginx::resource::vhost { "${sitename}_redirect":
    server_name          => ["${sitename}, aws-${sitename}"],
    listen_port          => 80,
    www_root             => "/var/venv/${appname}/source",
    index_files          => ['index.html'],
    use_default_location => false,
    raw_prepend          => [
     '## redirect all requests to use TLS. ##
      return 301 https://$host$request_uri;'
    ],
    raw_append           => [
     "## Deny illegal host headers.
      if (\$host !~* ^(${sitename}|aws-${sitename})$ ) {
        return 444;
      }"
    ],
  }
  nginx::resource::vhost { "${sitename}":
    server_name          => ["${sitename}, aws-${sitename}"],
    listen_port          => 8090,
    www_root             => "/var/venv/${appname}/source",
    index_files          => ['index.html'],
    use_default_location => false,
    raw_append           => [
     "## Deny illegal host headers.
      if (\$host !~* ^(${sitename}|aws-${sitename})$ ) {
        return 444;
      }"
    ],
  }
  nginx::resource::location { "${sitename}_root":
    ensure                      => 'present',
    location                    => '/',
    vhost                       => "${sitename}",
    www_root                    => "/var/venv/${appname}/source",
    index_files                 => [],
    uwsgi			=> "unix:/var/tmp/${appname}.sock"
  }

# Create Virtual Environment
  exec { "create_virtualenv_${appname}":
    command => "/usr/bin/virtualenv ${appname}",
    user    => "jenkins",
    cwd     => "/var/venv/",
    creates => "/var/venv/${appname}/",
    require => Package['python-virtualenv'],
  }

# Create Application Directories
  file { "/var/venv/${appname}":
    ensure  => 'directory',
    owner   => hiera("websites::deployment::user"),
    group   => 'www-data',
    mode    => '0640',
    require  => Exec["create_virtualenv_${appname}"],
  }
  file { "/var/venv/${appname}/releases":
    ensure  => 'directory',
    owner   => hiera("websites::deployment::user"),
    group   => 'www-data',
    mode    => '0640',
    require => File["/var/venv/${appname}"],
  }
  file { "/var/venv/${appname}/private":
    ensure  => 'directory',
    owner   => '0',
    group   => 'www-data',
    mode    => '0640',
    require => File["/var/venv/${appname}"],
  }

# TODO: create a modular local_settings.py file for the django app.

#  concat { "${appname}_local_settings.py":
#    ensure => 'file',
#    target => "/var/venv/${appname}/private/local_settings.py",
#    owner  => 'jenkins',
#    group  => 'www-data',
#    mode   => '0644',
#    require => File["/var/venv/${appname}"],
#  }
}
