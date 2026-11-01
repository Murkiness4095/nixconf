{
  flake.nixosModules.asusctl =
    { pkgs, ... }:

    {
      environment.systemPackages = with pkgs; [
        asusctl
        supergfxctl
      ];

      services.asusd = {
        enable = true;
      };

      # 开机极早期就把 EC 风扇曲线切到 quiet。
      # 原因：power-profiles-daemon 在 NixOS 里只被 D-Bus 激活（nixpkgs 只做 systemd.packages，
      # 不认 unit 里的 [Install]），登录会话访问它之前 platform_profile 一直是固件默认值，
      # TUF 按 balanced 风扇曲线狂转。asus-nb-wmi 已在 boot.kernelModules 里，sysfs 早就可用。
      systemd.services.asus-platform-profile-quiet = {
        description = "Set ASUS platform_profile to quiet as early as possible";
        wantedBy = [ "sysinit.target" ];
        after = [ "systemd-modules-load.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          for _ in $(seq 1 100); do
            [ -w /sys/firmware/acpi/platform_profile ] && break
            sleep 0.02
          done
          if [ -w /sys/firmware/acpi/platform_profile ]; then
            echo quiet > /sys/firmware/acpi/platform_profile
          fi
        '';
      };

      # 解决 asusd 重启后无法自动应用充电限制的 bug
      systemd.services.asus-battery-charge-limit = {
        description = "Set ASUS Laptop Battery Charge Limit to 60%";
        after = [
          "multi-user.target"
          "asusd.service"
        ];
        wantedBy = [ "multi-user.target" ];
        script = ''
          if [ -f /sys/class/power_supply/BAT0/charge_control_end_threshold ]; then
            echo 60 > /sys/class/power_supply/BAT0/charge_control_end_threshold
          elif [ -f /sys/class/power_supply/BAT1/charge_control_end_threshold ]; then
            echo 60 > /sys/class/power_supply/BAT1/charge_control_end_threshold
          fi
        '';
      };

      services.supergfxd = {
        enable = true;
        settings = {
          mode = "Hybrid"; # 开机默认 GPU 模式: "Integrated" / "Hybrid" / "Vfio"
          vfio_enable = false; # 是否启用 VFIO 直通
          vfio_save = false; # 是否保存 VFIO 状态
          always_reboot = false; # 切换模式后是否总是重启
          no_logind = false; # 是否禁用 logind 集成
          logout_timeout_s = 180; # 切换模式时等待会话退出的秒数
          hotplug_type = "None"; # 热插拔类型: "None" / "Asus"
        };
      };

      services.dbus.enable = true;
      security.polkit.enable = true;
      boot.kernelModules = [
        "asus-nb-wmi"
        "acpi_call"
      ];
    };
}
