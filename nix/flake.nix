{
  description = "Rob's nix-darwin system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    
    firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";

    ghostty =  "github:ghostty-org/ghostty";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, firefox-darwin, ghostty, ... }:
  let
    # Global variables
    username = "robert";
    system = "aarch64-darwin";
  in
  {
    darwinConfigurations."mbpro" = nix-darwin.lib.darwinSystem {
      inherit system;
      
      # Pass inputs to modules so we can use 'firefox-darwin' inside the config
      specialArgs = { inherit inputs; };

      modules = [
        ({ pkgs, config, inputs, ... }: {

          # ----------------------------------------------------------------
          # 1. NIX CONFIGURATION
          # ----------------------------------------------------------------
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          nixpkgs.config.allowUnfree = true;
          
          nixpkgs.overlays = [
            inputs.firefox-darwin.overlay
          ];

          # ----------------------------------------------------------------
          # 2. PACKAGES
          # ----------------------------------------------------------------
          environment.systemPackages = with pkgs; [
	    stow
            coreutils
            dockutil
            firefox-bin
            git
            neovim
          ];

          # ----------------------------------------------------------------
          # 3. USERS
          # ----------------------------------------------------------------
          users.users.${username} = {
            name = username;
            home = "/Users/${username}";
          };
          
          # Required for system.defaults (dock, finder, etc.) to apply to your user
          system.primaryUser = username;

          # ----------------------------------------------------------------
          # 4. SYSTEM SETTINGS
          # ----------------------------------------------------------------
          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.stateVersion = 6;
          
          programs.zsh.enable = true;

          system.defaults = {
            dock = {
              autohide = false;
              tilesize = 64;
              show-recents = false;
            };
            finder.FXPreferredViewStyle = "clmv";
            loginwindow.GuestEnabled = false;
            NSGlobalDomain.AppleInterfaceStyle = "Dark";
          };

          # ----------------------------------------------------------------
          # 5. ACTIVATION SCRIPT
          # ----------------------------------------------------------------
          system.activationScripts.applications.text = let
            env = pkgs.buildEnv {
              name = "system-applications";
              paths = config.environment.systemPackages;
              pathsToLink = [ "/Applications" ];
            };
          in pkgs.lib.mkForce ''
            echo "setting up /Applications..." >&2
            app_target="/Applications/Nix Apps"
            rm -rf "$app_target"
            mkdir -p "$app_target"

            if [ -d "${env}/Applications" ]; then
              find "${env}/Applications" -maxdepth 1 -type l | while read -r app; do
                src="$(/usr/bin/stat -f%Y "$app")"
                app_name="$(basename "$app")"
                dest="$app_target/$app_name"
                echo "copying $src to $dest" >&2
                cp -L -R "$src" "$dest"
                chmod -R 755 "$dest"
                chown -R "${username}:staff" "$dest"
              done
            fi
          '';
        })
      ];
    };
  };
}
