{
  perSystem = { pkgs, ... }:
    let
      neovim = pkgs.neovim.override {
        configure = {
          customRC = ''
            lua << NVIM_INIT
            ${builtins.readFile ./config/init.lua}
            NVIM_INIT
          '';
          packages.myVimPackage = with pkgs.vimPlugins; {
            start = [
              tokyonight-nvim
              nvim-web-devicons
              nvim-tree-lua
              telescope-nvim
              plenary-nvim
              lualine-nvim
              bufferline-nvim
              nvim-treesitter
              nvim-lspconfig
              nvim-cmp
              cmp-nvim-lsp
              cmp-buffer
              cmp-path
              luasnip
              conform-nvim
              trouble-nvim
              gitsigns-nvim
              which-key-nvim
              toggleterm-nvim
            ];
          };
        };
        extraPackages = with pkgs; [
          git
          ripgrep
          fd
          nil
          lua-language-server
          pyright
          rust-analyzer
          gopls
          typescript-language-server
          nixfmt
          stylua
          black
          rustfmt
          gofmt
          prettier
        ];
      };
    in
    {
      packages.nvim = neovim;
      packages.neovim = neovim;
    };
}