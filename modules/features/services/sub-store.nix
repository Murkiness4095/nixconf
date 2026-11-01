# Sub-Store —— 高级订阅管理器（后端 + PWA 前端），纯 nixpkgs 原生部署，无容器。
# 本文件是 sub-store.nix 的 Bun 运行时变体，对外仍使用 services.sub-store，
# 以便直接替换原模块；区别只有运行日从 Node.js 换成 Bun。
#
# 用法：
#   modules = [ (builtins.getFlake "path:/…/proxy").nixosModules.sub-store-bun ];
#   services.sub-store = { enable = true; port = 3002; };
#
# 注意：
# - 构建仍走 buildNpmPackage + pnpm，运行时 closure 不再包含 Node.js，只保留 Bun。
# - Bun 对 Node API 兼容性较好，但启用后请打开前端、新增/保存一个配置并观察日志。
{
  flake.nixosModules.sub-store =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.services.sub-store;

      # 与 sub-store.nix 一致：用上游官方 2.42.3 后端，避免 nixpkgs 旧版本不识别 mihomoConfig。
      sub-store-backend = pkgs.buildNpmPackage (finalAttrs: {
        pname = "sub-store";
        version = "2.42.3";

        src = pkgs.fetchFromGitHub {
          owner = "sub-store-org";
          repo = "Sub-Store";
          tag = finalAttrs.version;
          hash = "sha256-xiWmZ3iCmMUqY7v6Vbs6ksKTZVpKNkWK7Z5o6nTrfsE=";
        };

        sourceRoot = "${finalAttrs.src.name}/backend";

        nativeBuildInputs = [
          pkgs.makeBinaryWrapper
          pkgs.pnpm_11
        ];

        npmDeps = null;
        pnpmDeps = pkgs.fetchPnpmDeps {
          inherit (finalAttrs)
            pname
            version
            src
            sourceRoot
            ;
          pnpm = pkgs.pnpm_11;
          fetcherVersion = 4;
          hash = "sha256-EhLZOQGjc3A3wLsJyeV9P0woAewK8GWpQnyIRIYVgB8=";
        };

        npmConfigHook = pkgs.pnpmConfigHook;
        npmBuildScript = "bundle:esbuild";

        installPhase = ''
          runHook preInstall

          mkdir -p $out/share
          cp -r dist $out/share/sub-store
          makeWrapper ${lib.getExe pkgs.bun} $out/bin/sub-store \
            --add-flags "$out/share/sub-store/sub-store.bundle.js"

          runHook postInstall
        '';

        meta = {
          description = "Advanced Subscription Manager for QX, Loon, Surge, Stash, Egern and Shadowrocket (Bun runtime)";
          homepage = "https://github.com/sub-store-org/Sub-Store";
          changelog = "https://github.com/sub-store-org/Sub-Store/releases/tag/${finalAttrs.version}";
          license = lib.licenses.agpl3Only;
          mainProgram = "sub-store";
          platforms = lib.platforms.all;
        };
      });

      # StateDirectory 传的是相对 /var/lib 的目录名，这里从 dataDir 反推
      stateDirName = lib.last (lib.splitString "/" cfg.dataDir);

      environment = {
        # 后端监听地址/端口。默认监听所有网卡，保证局域网设备能直连 IP。
        SUB_STORE_BACKEND_API_HOST = cfg.listenAddress;
        SUB_STORE_BACKEND_API_PORT = toString cfg.port;
        # 单端口合并模式：后端同时托管前端静态文件，不需要额外反代/多开一个端口。
        SUB_STORE_BACKEND_MERGE = "true";
        # 合并模式下后端只处理 /backend/* ；其余路径返回前端静态文件（SPA 回退到 index.html）。
        # 因此后端地址 = http://<host>:<port>/backend，分享链接同理。
        SUB_STORE_FRONTEND_BACKEND_PATH = "/backend";
        SUB_STORE_FRONTEND_PATH = "${cfg.frontendPackage}";
        # 数据（订阅、脚本、产物等 JSON）落盘目录，默认即 systemd 的 StateDirectory
        SUB_STORE_DATA_BASE_PATH = cfg.dataDir;
        # 后端 2.26.0+ 起校验 Origin 白名单，本模块默认放开任意来源。
        SUB_STORE_CORS_ALLOWED_ORIGINS = cfg.corsAllowedOrigins;
      }
      // cfg.environment;
    in
    {
      options.services.sub-store = {
        enable = lib.mkEnableOption "Sub-Store 订阅管理器";

        package = lib.mkOption {
          type = lib.types.package;
          default = sub-store-backend;
          defaultText = lib.literalExpression "sub-store-backend (upstream 2.42.3, Bun runtime)";
          description = ''
            Sub-Store 后端包（提供 bin/sub-store）。
            默认使用本模块自带的 2.42.3 官方后端，并以 Bun 作为运行时。
          '';
        };

        frontendPackage = lib.mkOption {
          type = lib.types.package;
          default = pkgs.sub-store-frontend;
          defaultText = lib.literalExpression "pkgs.sub-store-frontend";
          description = "Sub-Store 前端 PWA 静态资源包（合并模式下由后端托管）。";
        };

        port = lib.mkOption {
          type = lib.types.port;
          default = 3000;
          description = "后端监听端口，同时用于托管前端。";
        };

        listenAddress = lib.mkOption {
          type = lib.types.str;
          default = "0.0.0.0";
          description = ''
            后端监听地址。默认 0.0.0.0 表示监听所有网卡，局域网其他设备可用本机 IP 访问。
            想只走 IPv6/双栈可改成 "::"（上游默认值），只想本机访问则改成 "127.0.0.1"。
          '';
        };

        corsAllowedOrigins = lib.mkOption {
          type = lib.types.str;
          default = "*";
          example = "https://sub-store.vercel.app,http://substore.stash,https://substore.stash,http://192.168.31.7:${toString cfg.port}";
          description = ''
            SUB_STORE_CORS_ALLOWED_ORIGINS：浏览器跨域访问后端时允许的 Origin 白名单。
            多个 origin 用 `,` 分隔，每个 origin 需含协议、域名、端口、不含路径；
            "*" 表示允许任意来源。
          '';
        };

        dataDir = lib.mkOption {
          type = lib.types.str;
          default = "/var/lib/sub-store";
          description = ''
            数据目录，存放 root.json / subs.json / artifacts.json 等。
            必须是 /var/lib 下的路径（systemd StateDirectory 才能创建并授权）。
          '';
        };

        environment = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          example = {
            # 走上游代理拉取订阅
            SUB_STORE_BACKEND_DEFAULT_PROXY = "http://127.0.0.1:7890";
            # 定时同步订阅（cron 表达式）
            SUB_STORE_BACKEND_SYNC_CRON = "0 0 * * *";
          };
          description = ''
            追加的 SUB_STORE_* 环境变量，会覆盖本模块的同名默认值。
            完整变量列表见上游 backend/src/restful/index.js 与 utils/env.js。
          '';
        };

        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            是否在 NixOS 防火墙放行配置文件的端口。
            没开防火墙的主机上不需要，保持 false 即可；开了 networking.firewall 的机器设为 true。
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        systemd.services.sub-store = {
          description = "Sub-Store 订阅管理器";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = lib.getExe cfg.package;
            StateDirectory = stateDirName;
            StateDirectoryMode = "0750";
            WorkingDirectory = cfg.dataDir;
            # ProtectHome 下 HOME 不可用，指向数据目录，避免个别库找 ~/.cache 之类的路径
            Environment = [
              "HOME=${cfg.dataDir}"
            ]
            ++ lib.mapAttrsToList (name: value: "${name}=${value}") environment;
            Restart = "on-failure";
            RestartSec = 5;
            # 基础加固：只需要读 /nix/store，写自己的数据目录
            NoNewPrivileges = true;
            PrivateTmp = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            ProtectKernelTunables = true;
            ProtectControlGroups = true;
            RestrictSUIDSGID = true;
          };
        };

        # 未配置防火墙的主机无需此段；若 networking.firewall 启用，把 openFirewall 设为 true。
        networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
      };
    };
}
