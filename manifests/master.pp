class cluster::master (
    $workers ,
    $management_user_home,
    $management_key_source,
    $worker_mem,
    $mount_to_device_map = $::cluster::defaults::mount_to_device_map,
    $name_dir = $::cluster::defaults::name_dir
) inherits cluster::defaults {

    
    # Unable to pass parameters to base class in 2.7; This is a workaround.
    class {'cluster':
        master                => "${::fqdn}",
        workers               => $workers,
        mount_to_device_map   => $mount_to_device_map,
        management_user_home  => $management_user_home,
        management_key_source => $management_key_source,
        name_dir              => $name_dir,
    }
    Class['cluster'] -> Class['cluster::master']
    

    class {'cdh4::hadoop::master':
    }

    class {'impala::master':
    }

    class { '::mysql::server':
      root_password    => 'cluster',
    }

    class { 'hive::master': 
        require => Class['::mysql::server'],
        
    }

    class {'spark::master':
    }
    
    class {'shark':
        master              => "${::fqdn}",
        spark_worker_memory => $worker_mem,
    }


}
