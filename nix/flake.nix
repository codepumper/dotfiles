{
  description = "Rob's Minimal Mac Host";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, nix-homebrew, ... }:
  let
    username = "robert";
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
         environment.variables = { GIT_TERMINAL_PROMPT = "0"; };

         # 2. CLI PACKAGES
         environment.systemPackages = with pkgs; [
            devpod
            git
            stow
            coreutils
            dockutil
            starship
         ];

         # 3. HOMEBREW CONFIGURATION
         nix-homebrew = {
           enable = true;
           enableRosetta = true;
           user = username;
           autoMigrate = true;
         };

         homebrew = {
           enable = true;
           onActivation = { autoUpdate = true; cleanup = "zap"; };
           casks = [ "orbstack" "ghostty" "firefox" ];
         };

         # 4. USERS
         users.users.${username} = {
           name = username;
           home = "/Users/${username}";
         };
         system.primaryUser = username;

         # 5. SYSTEM DEFAULTS
         system.configurationRevision = self.rev or self.dirtyRev or null;
         system.defaults = {
           dock = {
             autohide = false;
             tilesize = 64;
             show-recents = false;
             persistent-apps = [ "/Applications/Ghostty.app" "/Applications/Firefox.app" ];
           };
           finder.FXPreferredViewStyle = "clmv";
           loginwindow.GuestEnabled = false;
           NSGlobalDomain.AppleInterfaceStyle = "Dark";
         };

         # 6. SHELL CONFIG
         programs.zsh = {
           enable = true;
           promptInit = "eval \"$(starship init zsh)\"";
	   interactiveShellInit = ''
             clear
             cd ~/Dev
           '';
         };

         # 7. ACTIVATION SCRIPT (FIXED USER PERMISSIONS)
         system.activationScripts.applications.text = let
           env = pkgs.buildEnv {
             name = "system-applications";
             paths = config.environment.systemPackages;
             pathsToLink = [ "/Applications" ];
           };
           devpodPath = "${pkgs.devpod}/bin/devpod";
         in pkgs.lib.mkForce ''
           echo "setting up /Applications..." >&2
           app_target="/Applications/Nix Apps"
           
           # Clean and Re-link Apps
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
           
           # Configure DevPod (Running as ${username})
           # 3. Configure DevPod (Running as ${username})
           if [ -x "${devpodPath}" ]; then
             echo "🚀 Configuring DevPod Provider for ${username}..."
             
             # FIX: Explicitly set PATH so DevPod can find the 'docker' binary
             # and force HOME to ensure config goes to /Users/robert/.devpod
             sudo -u ${username} PATH=$PATH:/opt/homebrew/bin:/usr/local/bin HOME=/Users/${username} \
               ${devpodPath} provider add docker >/dev/null 2>&1 || true
             
             sudo -u ${username} PATH=$PATH:/opt/homebrew/bin:/usr/local/bin HOME=/Users/${username} \
               ${devpodPath} provider use docker >/dev/null 2>&1
           fi
         '';

	 system.activationScripts.createDevFolder.text = ''
           echo "Checking for Dev folder..."
           if [ ! -d "/Users/${username}/Dev" ]; then
             echo "Creating Dev folder..."
             mkdir -p "/Users/${username}/Dev"
             chown ${username}:staff "/Users/${username}/Dev"
           fi
         '';

         # 8. STATE VERSION (This caused your error!)
         system.stateVersion = 6;
         
       })
     ];
   };
 };
}