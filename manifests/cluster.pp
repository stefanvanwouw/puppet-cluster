class cluster (
    $master,
    $workers,
    $mount_to_device_map,
    $management_key_source,
    $management_user_home,
    $worker_mem,
    $mode,
    $mount_options = $::cluster::defaults::mount_options,
    $fs_type = $::cluster::defaults::fs_type,
    $name_dir = $::cluster::defaults::name_dir,
    $data_dirs = $::cluster::defaults::data_dirs,
) inherits cluster::defaults {
    require cluster::remove-conflicts
    
    class {'cluster::requirements':
	mode => $mode,
    }
    Class['cluster::requirements'] -> Class['cluster']

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
        yarn_nodemanager_resource_memory_mb => $mode ? {
            'hive' => 61440, # TODO: Make this nice, default 60g.
            default => 8192,
        },
        require            => Cluster::Mount[$mount_dirs],
    }

    $zookeeper_hosts = concat([$master], $workers)
    class { 'hive':
      metastore_host  => $master,
      zookeeper_hosts => $zookeeper_hosts,
      jdbc_password   => 'cluster',
      require         => Class['cdh4::hadoop'],
    }


    class {'shark':
        master              => $master,
        spark_worker_memory => $worker_mem,
    }

    class { 'zookeeper':
        hosts    => hash(flatten(zip($zookeeper_hosts, range('1', size($zookeeper_hosts))))),
        data_dir => '/var/lib/zookeeper',
    }
    class { 'zookeeper::server': }


#    class {'ganglia::client': 
#        cluster => 'cluster',
#        network_mode => 'unicast',
#        unicast_targets => [
#            {'ipaddress' => $master, 'port' => '8649'}
#        ],
#        send_metadata_interval => 5,
#    }

}
