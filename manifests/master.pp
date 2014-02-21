class cluster::master (
    $workers ,
    $management_user_home,
    $management_key_source,
    $worker_mem,
    $mode,
    $mount_to_device_map = $::cluster::defaults::mount_to_device_map,
    $name_dir = $::cluster::defaults::name_dir
) inherits cluster::defaults {

    
    # Unable to pass parameters to base class in 2.7; This is a workaround.
    class {'cluster':
        worker_mem            => $worker_mem,
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
        impala_service_status => $mode ? {
            'impala' => 'running',
            default  => 'stopped'
        },
    }

    class { '::mysql::server':
      root_password    => 'cluster',
    }

    class { 'hive::master': 
        require => Class['::mysql::server'],
        
    }

    class {'spark::master':
        spark_service_status => $mode ? {
            'spark' => 'running',
            default => 'stopped',
        },
        worker_mem => $worker_mem,
    }
    

#    class {'presto::master':
#    }

#    class {'ganglia::server': 
#        gridname => 'Benchmark',
#        clusters => [
#            {
#                cluster_name => 'cluster', 
#                cluster_hosts => concat([$::fqdn],$workers),
#            }
#        ],
#        
#    }
    
#    class { 'apache':
#        default_vhost => false,
#        mpm_module => 'prefork',
#    }
#    include apache::mod::php
#
#    class {'ganglia::webserver': 
#    }  


}
