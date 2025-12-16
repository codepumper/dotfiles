{
  description = "Linux Dev Container - Python, Neovim, Rust";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # --- THE EDITOR STACK ---
	    readline
	    ncurses
            neovim
            git
            ripgrep      # For Telescope
            fd           # For Telescope
            fzf
            
            # Dependencies for Nvim Plugins (Treesitter/Mason)
	    clang-tools
            gcc # Needed to compile parsers
            gnumake
            unzip
            gzip
            nodejs_22 # Needed for Copilot/LSPs
            
	    python314
            uv
            
	    rustup
            # R
            # rPackages.languageserver
          ];

          shellHook = ''
            echo "🐧 Welcome to the Linux Workbench"
            echo "🐍 Python: $(python3 --version)"
          '';
        };
      }
    );
}
