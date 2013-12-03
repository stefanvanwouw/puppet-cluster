class cluster::management (
    $user_home,
    $key_source,
) {

    $home_split = split($user_home,'/')
    $user = $home_split[size($home_split)-1]

    ssh_authorized_key { 'cluster_access':
        user   => $user,
        ensure => present,
        key    => sshkey_public_key_from_private_key(file($key_source)),
        type   => ssh-rsa,
    }

    file {"${user_home}/.ssh":
        ensure => directory,
        owner  => $user,
        group  => $user,
    }

    file {"${user_home}/.ssh/id_rsa":
        content  => file($key_source),
        mode     => '0400',
        owner    => $user,
        group    => $user,
        require  => File["${user_home}/.ssh"],
    }

}
