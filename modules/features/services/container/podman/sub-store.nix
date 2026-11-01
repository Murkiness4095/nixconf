{
  flake.nixosModules.sub-store-oci = {
    virtualisation = {
      podman.enable = true;
      oci-containers = {
        backend = "podman";
        containers.sub-store = {
          image = "docker.io/xream/sub-store:latest";
          ports = [ "3001:3001" ]; # 映射到 3001 端口
          volumes = [
            "/var/lib/sub-store/data:/opt/app/data"
          ];
          environment = {
            TZ = "Asia/Shanghai";
            SUB_STORE_FRONTEND_BACKEND_PATH = "/3001"; # 搭配WebUI时的默认前端接口路径配置
            SUB_STORE_CORS_ALLOWED_ORIGINS = "*"; # 允许本地前端 Origin 发起请求（注意包含协议和端口）
          };
          labels = {
            "io.containers.autoupdate" = "registry"; # 开启 Podman 自动更新
          };
          autoStart = true;
        };
      };
    };

    # 自动创建持久化数据目录
    systemd.tmpfiles.rules = [
      "d /var/lib/sub-store      0755 root root -"
      "d /var/lib/sub-store/data 0755 root root -"
    ];

    # 开启 Podman 自动更新定时器
    systemd.timers."podman-auto-update".wantedBy = [ "timers.target" ];
  };
}
