class cluster::requirements {
   
    package {'git':
        ensure => installed,
    }

    apt::source {'cdh4':
        location     => 'http://archive.cloudera.com/cdh4/ubuntu/precise/amd64/cdh',
        release      => 'precise-cdh4',
        repos        => 'contrib',
        architecture => 'amd64',
        include_src  => false,
        key          => '02A818DD',
        key_server   => 'keys.gnupg.net'
    }

    apt::source {'webupd8team-java':
        location => 'http://ppa.launchpad.net/webupd8team/java/ubuntu',
        release  => 'precise',
        repos    => 'main',
        key      => 'EEA14886'
    }
 
   
    exec { 'accept-java-license':
        command => '/bin/echo /usr/bin/debconf shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections;/bin/echo /usr/bin/debconf shared/accepted-oracle-license-v1-1 seen true | sudo /usr/bin/debconf-set-selections;',
        creates => '/usr/lib/jvm/java-6-oracle'
      }

    package { 'oracle-java6-installer':
       ensure  => installed,
       require => [Apt::Source['webupd8team-java'], Exec['accept-java-license']],
    }
}