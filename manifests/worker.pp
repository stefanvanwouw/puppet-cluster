class cluster::worker (
    $master,
    $workers,
    $management_user_home,
    $management_key_source,
    $worker_mem,
    $data_dirs = $::cluster::defaults::data_dirs,
    $mount_to_device_map = $::cluster::defaults::mount_to_device_map,
) inherits cluster::defaults {


    # Unable to pass parameters to base class in 2.7; This is a workaround.
    class {'cluster':
        master                => $master,
        workers               => $workers,
        mount_to_device_map   => $mount_to_device_map,
        management_user_home  => $management_user_home,
        management_key_source => $management_key_source,
        data_dirs             => $data_dirs,
    }
    Class['cluster'] -> Class['cluster::worker']


    class {'cdh4::hadoop::worker':
    }
    class {'impala::worker':
        impala_state_store_host => $master,
        require                 => Class['cdh4::hadoop::worker'],
    }

    class {'spark::worker':
        master  => $master,
        memory  => $worker_mem,
        require => Class['cdh4::hadoop::worker'],
    }

#    class {'presto::worker':
#        master => $master,
#    }


}
