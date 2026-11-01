{
  self,
  ...
}:
{
  flake.nixosModules.core-pkgs =
    { pkgs, user, ... }:
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

      environment.systemPackages = with pkgs; [
        just
        selfpkgs.fastfetch
        microfetch
        gh
        btop
        wlr-randr
        tree
        nh
        nix-output-monitor
        nvd
        nix-tree
        nil
        nixfmt
        nixpkgs-fmt
        mcp-nixos
        tmux
        yazi

        ffmpeg-full
        file # 用于检测文件类型
        imagemagick # 图片预览核心
        ffmpegthumbnailer # 视频预览
        # poppler-utils       # PDF 预览
        (lib.lowPrio poppler-utils)
        fd # 快速文件搜索
        ripgrep # 内容搜索
        fzf # 模糊找文件
      ];
    };
}
