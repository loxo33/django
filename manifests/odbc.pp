class django::odbc {

  package {['freetds-common','freetds-bin','tdsodbc', 'g++', 'unixodbc-dev',]:
    ensure   => installed,
  }

  concat { '/etc/odbc.ini':
    ensure => present,
    path   => '/etc/odbc.ini',
    owner  => "0",
    group  => "0",
    mode   => "0644",
  }

  concat { '/etc/freetds/freetds.conf':
    ensure => present,
    path   => '/etc/freetds/freetds.conf',
    owner  => "0",
    group  => "0",
    mode   => "0644",
  }
  concat::fragment{ "freetds.conf_header_${name}":
    target  => '/etc/freetds/freetds.conf',
    order   => '01',
    content => template('django/freetds.conf_header.erb'),
  }
  file {'/etc/odbcinst.ini':
    ensure => file,
    owner   => "0",
    group   => "0",
    mode    => "0644",
    content => template('django/odbcinst.ini.erb'),
  }
}

# Used by other modules to register connection strings to the odbc config file
define django::odbc::connector(
    $driver      = "FreeTDS",
    $description = "ODBC connection via FreeTDS",
    $trace       = "No",
    $servername  = undef,
    $database    = undef,
    $driver_path = "/usr/lib/x86_64-linux-gnu/odbc/libtdsodbc.so",
    $serverport  = "1433",
    $tds_vers    = "8.0",
    $order       = "10",
 ) {

  include django::odbc
  
    concat::fragment{ "odbc.ini_fragment_${name}":
      target  => '/etc/odbc.ini',
      order   => $order,
      content => template('django/connector.erb'),
    }
  
    concat::fragment{ "freetds.conf_fragment_${name}":
      target  => '/etc/freetds/freetds.conf',
      order   => $order,
      content => template('django/freetds.conf_connection.erb'),
    }
}
