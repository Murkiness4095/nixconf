{
  flake.nixosModules.power = {
    services.upower.enable = true; # 电池与电源管理
    services.power-profiles-daemon.enable = true; # 性能模式切换

    # 上游 unit 只有 [Install] WantedBy=graphical.target，NixOS 不处理 [Install]，
    # 于是 PPD 平时只能靠 D-Bus 激活（登录后才起来）。这里让它随开机启动，
    # 使保存的 profile（现在是 power-saver）在登录前就生效。
    systemd.services.power-profiles-daemon.wantedBy = [ "multi-user.target" ];

    services.tlp = {
      enable = false;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
    };
  };
}
