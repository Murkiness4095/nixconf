{
  flake.nixosModules.new-api-oci = {
    virtualisation = {
      podman.enable = true;
      oci-containers = {
        backend = "podman";
        containers.new-api = {
          image = "docker.io/calciumion/new-api:latest";
          ports = [ "3000:3000" ];
          volumes = [
            "/var/lib/new-api/data:/data"
            "/var/lib/new-api/logs:/app/logs"
          ];
          environment = {
            TZ = "Asia/Shanghai";
            # SQL_DSN = "...";
            # REDIS_CONN_STRING = "...";
          };
          labels = {
            "io.containers.autoupdate" = "registry"; # 开启 Podman 自动更新
          };
          autoStart = true;
        };
      };
    };

    # 自动创建数据目录
    systemd.tmpfiles.rules = [
      "d /var/lib/new-api      0755 root root -"
      "d /var/lib/new-api/data 0755 root root -"
      "d /var/lib/new-api/logs 0755 root root -"
    ];

    # 开启 Podman 自动更新定时器（默认每天跑一次）
    systemd.timers."podman-auto-update".wantedBy = [ "timers.target" ];
  };
}
