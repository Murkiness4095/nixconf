{ self, ... }:
{
  flake.nixosModules.base-pkgs =
    {
      pkgs,
      lib,
      user,
      ...
    }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      programs.fish = {
        enable = true;
        package = selfpkgs.fish;
      };

      programs.starship = {
        enable = true;
        package = selfpkgs.starship;
      };

      users.users.${user}.shell = selfpkgs.fish;

      programs.yazi = {
        enable = true;
        package = pkgs.yazi;
      };

      environment.systemPackages =
        with pkgs;
        [
          # base
          selfpkgs.git
          selfpkgs.fastfetch
          selfpkgs.neovim
          vim
          wget
          curl

          just

          atftp # 或者 tftp-hpa

          whois
          lshw
          smartmontools
          parted
          dmidecode
          nix-ld
          tree
          icu

          sops

          # CLI / dev tools
          gh
          btop
          wlr-randr
          nh
          nix-output-monitor
          nvd
          nix-tree
          nil
          nixfmt
          nixpkgs-fmt
          mcp-nixos
          herdr

          # yazi preview deps
          file # 用于检测文件类型
          fd # 快速文件搜索
          ripgrep # 内容搜索
          fzf # 模糊找文件
          imagemagick # 图片预览核心
          ffmpegthumbnailer # 视频预览
          (lib.lowPrio poppler-utils)
          ffmpeg-full

          microfetch
        ]
        ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
          selfpkgs.napcat
        ];
    };
}
