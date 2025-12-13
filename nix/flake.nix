{
  description = "Rob's nix-darwin system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, nix-homebrew, ... }:
  let
    username = "Robert";
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    darwinConfigurations."mbpro" = nix-darwin.lib.darwinSystem {
      inherit system;
      modules = [
        nix-homebrew.darwinModules.nix-homebrew
        ({ pkgs, config, ... }: {

          # 1. NIX SETTINGS
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          nixpkgs.config.allowUnfree = true;

          # 2. SAFETY SWITCH
          # This forces the installer to NEVER ask for a password.
          # If it hits a login wall, it will skip it and keep going.
          environment.variables = {
            GIT_TERMINAL_PROMPT = "0"; 
          };

          # 3. CLI PACKAGES
          environment.systemPackages = with pkgs; [
            stow
            coreutils
            dockutil
            git
            neovim
            starship
          ];

          # 4. HOMEBREW CONFIGURATION
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = username;
            autoMigrate = true;
          };

          homebrew = {
            enable = true;
            onActivation = {
              autoUpdate = true;
              cleanup = "zap"; 
            };
            
            # Taps removed as requested
            
            casks = [
              "ghostty"
              "firefox"
            ];
          };

          # 5. USERS
          users.users.${username} = {
            name = username;
            home = "/Users/${username}";
          };
          system.primaryUser = username;

          # 6. SYSTEM DEFAULTS
          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.defaults = {
            dock = {
              autohide = false;
              tilesize = 64;
              show-recents = false;
              persistent-apps = [
                "/Applications/Ghostty.app"
                "/Applications/Firefox.app"
              ];
            };
            finder.FXPreferredViewStyle = "clmv";
            loginwindow.GuestEnabled = false;
            NSGlobalDomain.AppleInterfaceStyle = "Dark";
          };

          # 7. SHELL CONFIG
          programs.zsh = {
            enable = true;
            # Initialize Starship
            promptInit = "eval \"$(starship init zsh)\"";
            # Force a clear screen when the shell starts
            interactiveShellInit = ''
              clear
            '';
          };

          # 8. ACTIVATION SCRIPT
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
	    rm -rf "$app_target"
          '';

          system.stateVersion = 6;
          
	
        })
      ];
    };
  };
}