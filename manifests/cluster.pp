class cluster (
    $master,
    $workers,
    $mount_to_device_map,
    $management_key_source,
    $management_user_home,
    $mount_options = $::cluster::defaults::mount_options,
    $fs_type = $::cluster::defaults::fs_type,
    $name_dir = $::cluster::defaults::name_dir,
    $data_dirs = $::cluster::defaults::data_dirs,
) inherits cluster::defaults {
    require cluster::remove-conflicts
    require cluster::requirements

    class {'cluster::management':
        key_source  => $management_key_source,
        user_home   => $management_user_home,
    }
    


    $mount_dirs = keys($mount_to_device_map)
    cluster::mount {$mount_dirs:
        mount_options       => $mount_options,
        fs_type             => $fs_type,
        mount_to_device_map => $mount_to_device_map,
    }


    
    class { 'cdh4::hadoop':
        namenode_hosts     => [$master],
        datanode_mounts    => $data_dirs,
        ganglia_hosts      => ["${master}:8649"],
        dfs_name_dir       => $name_dir,
        require            => cluster::mount[$mount_dirs],
    }

    $zookeeper_hosts = concat([$master], $workers)
    class { 'hive':
      metastore_host  => $master,
      zookeeper_hosts => $zookeeper_hosts,
      jdbc_password   => 'cluster',
      require         => Class['cdh4::hadoop'],
    }



    class { 'zookeeper':
        hosts    => hash(flatten(zip($zookeeper_hosts, range('1', size($zookeeper_hosts))))),
        data_dir => '/var/lib/zookeeper',
    }
    class { 'zookeeper::server': }


}
