class cluster::defaults {
    $mount_options = 'nodiratime,noatime'

    $fs_type = 'ext3'

    $mount_to_device_map = {
        '/data0' => '/dev/xvdb',
        '/data1' => '/dev/xvdc',
    }
    
    # Data dirs, cannot be equal to the mount root (e.g., /data0/hadoop would work).
    $data_dirs = ['/data0/hadoop', '/data1/hadoop']

    $name_dir = '/name'

    

}
