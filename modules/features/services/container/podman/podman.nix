{
  flake.nixosModules.podman = { user, ... }: {
    virtualisation.podman = {
      enable = true;
      # 自动安装 subuid/subgid 映射所需的影子工具配置
      dockerCompat = false; # 如果不需要 alias docker=podman 可以保持 false
    };
    users.users.${user} = {
      # Rootless Podman
      subUidRanges = [
        {
          startUid = 100000;
          count = 65536;
        }
      ];

      subGidRanges = [
        {
          startGid = 100000;
          count = 65536;
        }
      ];

      # 允许 systemd --user 在用户退出登录后继续运行
      linger = true;
    };
  };
}
