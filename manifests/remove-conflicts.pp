class cluster::remove-conflicts {

    # Make sure the default OpenJDK VMs are uninstalled or impalad will segfault.
    package {['icedtea-6-jre-cacao', 'icedtea-6-jre-jamvm']:
        ensure => absent
    }

    mount {'/mnt':
        device => '/dev/xvdb',
        ensure => absent,
        atboot => true
    }
}
