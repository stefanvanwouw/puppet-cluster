define cluster::mount (
    $mount_options, $fs_type, $mount_dir = $title, $mount_to_device_map
) {
    
    file {$mount_dir:
        ensure => directory,
    }
    

    mount {$mount_dir:
        device  => $mount_to_device_map[$mount_dir],
        fstype  => $fs_type,
        ensure  => mounted,
        options => $mount_options,
        atboot  => true,
        require => File[$mount_dir],
    }
}
