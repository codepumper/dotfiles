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
            # --- 1. THE EDITOR STACK ---
	    readline
            neovim
            git
            ripgrep      # For Telescope
            fd           # For Telescope
            fzf
            
            # Dependencies for Nvim Plugins (Treesitter/Mason)
            gcc          # Needed to compile parsers
            gnumake
            unzip
            gzip
            nodejs_22    # Needed for Copilot/LSPs
            
            # --- 2. THE LANGUAGE STACK ---
            # Python + Prefect
            (python311.withPackages (ps: with ps; [
              prefect
              pandas
              numpy
              virtualenv
              pip
            ]))
            
            # Rust (If you still need it)
            rustup
            
            # R (If you still need it)
            R
            rPackages.languageserver
          ];

          shellHook = ''
            echo "🐧 Welcome to the Linux Workbench"
            echo "📦 Python: $(python3 --version)"
            echo "🚀 Neovim: $(nvim --version | head -n 1)"
          '';
        };
      }
    );
}
