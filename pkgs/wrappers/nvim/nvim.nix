{
  perSystem = { pkgs, ... }:
    {
      packages.nvim = pkgs.neovim;
      packages.neovim = pkgs.neovim;
    };
}
