{
  inputs,
  self,
  ...
}:
{
  flake.nixosConfigurations.guix = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.node-guix
    ];
  };

  flake.nixosModules.node-guix =
    { pkgs, ... }:
    let
      nixpakApps = inputs.nixpak-apps.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      imports = [
        # modules
      ];

      environment.systemPackages = with pkgs; [
        # nixpak-apps
        nixpakApps.vesktop # 内置 Vencord 的 Discord 替代客户端
        nixpakApps.nheko # Desktop client for the Matrix protocol
        nixpakApps.telegram
        nixpakApps.dingtalk
        nixpakApps.feishu
        nixpakApps.qq
        nixpakApps.wechat
        nixpakApps.wechat-uos
      ];
    };
}
