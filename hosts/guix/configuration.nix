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
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      imports = [
        # modules
      ];

      environment.systemPackages = with pkgs; [
        # chat
        deltachat-desktop
        selfpkgs.aerion
        selfpkgs.vesktop # 内置 Vencord 的 Discord 替代客户端
        selfpkgs.nheko # Desktop client for the Matrix protocol
        selfpkgs.telegram
        selfpkgs.dingtalk
        selfpkgs.feishu
        selfpkgs.qq
        selfpkgs.wechat
        selfpkgs.wechat-uos
      ];
    };
}
