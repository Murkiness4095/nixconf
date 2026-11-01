{
  flake.nixosModules.nvidia =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.my.nvidia;
    in
    {
      options.my.nvidia = {
        enable = lib.mkEnableOption "NVIDIA + Intel hybrid graphics configuration";

        # 核心选项：是否使用开源内核模块
        open = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Whether to use the open-source NVIDIA kernel modules.
            - true  = open kernel modules (Turing+)
            - false = proprietary kernel modules
          '';
        };

        # 可选：驱动分支
        package = lib.mkOption {
          type = lib.types.package;
          default = config.boot.kernelPackages.nvidiaPackages.stable;
          description = "NVIDIA driver package to use (stable / production / beta / latest ...)";
        };
      };

      config = lib.mkIf cfg.enable {
        # Enable OpenGL
        hardware.graphics = {
          enable = true;
          enable32Bit = true;
          extraPackages = with pkgs; [
            intel-media-driver # Intel 集显硬解
            vpl-gpu-rt # QSV 编解码支持
            # intel-compute-runtime
          ];
        };

        # For offloading, modesetting is needed additionally
        services.xserver.videoDrivers = [
          "modesetting"
          "nvidia"
        ];

        hardware.nvidia = {
          open = cfg.open; # 由 option 控制
          modesetting.enable = true; # Wayland
          nvidiaSettings = true;
          package = cfg.package;

          powerManagement = {
            enable = true;
            finegrained = true;
          };

          prime = {
            offload = {
              enable = true;
              enableOffloadCmd = true;
            };
            # 改成你的实际 Bus ID
            intelBusId = "PCI:0:2:0";
            nvidiaBusId = "PCI:1:0:0";
          };
        };

        environment.sessionVariables = {
          LIBVA_DRIVER_NAME = "iHD";
        };
      };
    };
}
