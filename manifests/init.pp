# Install and manage Django sites.
# TODO: 
# fix package/params messiness below. Pip is not a reliable "provider" in Puppet. 
# fix docroot directory ownership; this should be hiera-defined. 
class django (
) inherits ::django::params {

  package { ['python-pip', 'python-virtualenv', 'python-dev',]:
    ensure => installed,
  }
  file { "/var/venv":
    ensure => directory,
    owner  => "jenkins",
    group  => "jenkins",
    mode   => "0644",
  }

#  package { $django_packages:
#    ensure   => installed,
#    provider => 'pip',
#  }
}
