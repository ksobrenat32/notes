# Service notes

## Service Example

    [Unit]
    Description=My awesome app
    Documentation=https://github.com/user/my_awesome_app
    # Require network if you need it
    After=network.target
    
    [Service]
    # The user/group the service is run under (optional, default is root).
    User=awesome_user
    Group=awesome_group
    # The location of the .env file for configuration (optional).
    EnvironmentFile=/etc/app.env
    # The location of the compiled binary.
    ExecStart=/usr/bin/app
    # Set reasonable connection and process limits (optional).
    LimitNOFILE=1048576
    LimitNPROC=64
    # Isolate app from the rest of the system
    PrivateTmp=true
    PrivateDevices=true
    ProtectHome=true
    ProtectSystem=strict
    # Only allow writes to the following directory and set it to the working directory
    WorkingDirectory=/var/lib/app
    ReadWriteDirectories=/var/lib/app
    # Allow vaultwarden to bind ports in the range of 0-1024 (optional).
    #AmbientCapabilities=CAP_NET_BIND_SERVICE

    [Install]
    WantedBy=multi-user.target
