{ ... }:

{
  # Home Manager via nix-darwin. Source of truth for dotfiles lives in ../../files/.
  #
  # Workflow:
  #   1. Edit files in files/dotfiles/ or files/config/<app>/
  #   2. darwin-rebuild build --flake .#Malins-MacBook-Pro
  #   3. darwin-rebuild switch --flake .#Malins-MacBook-Pro
  #
  # First switch backs up any existing files to *.hm-backup instead of overwriting.
  #
  # Intentionally NOT managed (left in place):
  #   - ~/.config/raycast (977M database), opencode (node_modules), kilo (61M),
  #     clash, goose, agents, github-copilot -> app data/caches, would bloat /nix/store.
  #   - ~/.config/gh/hosts.yml, ~/.git-credentials, ~/.config/opencode/opencode.json
  #     -> contain OAuth tokens / API keys. Use sops-nix if you want them declarative.
  #   - ~/.config/zed/conversations|prompts|themes, ~/.config/opencode/plugins|skills
  #     -> caches/state. Only settings.json + keymap.json are managed.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";

    users.malinruwanpathirana = {
      home.stateVersion = "25.05";
      home.username = "malindhamsara";
      home.homeDirectory = "/Users/malindhamsara";

      programs.home-manager.enable = true;

      # --- shell / git / vim dotfiles (-> $HOME/.*) ---
      home.file = {
        ".zshrc".source = ../../files/dotfiles/zshrc;
        ".zshenv".source = ../../files/dotfiles/zshenv;
        ".gitconfig".source = ../../files/dotfiles/gitconfig;
        ".vimrc".source = ../../files/dotfiles/vimrc;

        # Ghostty keeps its config outside ~/.config on macOS.
        "Library/Application Support/com.mitchellh.ghostty/config".source =
          ../../files/config/ghostty/config;

        # Raycast preferences (plists only — databases/caches in
        # ~/Library/Application Support/com.raycast.macos stay unmanaged).
        # NOTE: macOS cfprefsd may replace these symlinks with regular files
        # when you change settings in-app; next switch restores them.
        "Library/Preferences/com.raycast.macos.plist".source =
          ../../files/config/raycast/com.raycast.macos.plist;
        "Library/Preferences/com.raycast.macos.v1.plist".source =
          ../../files/config/raycast/com.raycast.macos.v1.plist;
        "Library/Preferences/com.raycast-x.macos.plist".source =
          ../../files/config/raycast/com.raycast-x.macos.plist;
      };

      # --- ~/.config/* (XDG) ---
      xdg.configFile = {
        "starship/starship.toml".source = ../../files/config/starship/starship.toml;

        # Whole directories (recursive so new files are picked up).
        "nvim".source = ../../files/config/nvim;
        "nvim".recursive = true;

        # Zed: only real settings, not conversation/prompt caches.
        "zed/settings.json".source = ../../files/config/zed/settings.json;
        "zed/keymap.json".source = ../../files/config/zed/keymap.json;

        # gh CLI: config only. hosts.yml (tokens) stays unmanaged in place.
        "gh/config.yml".source = ../../files/config/gh/config.yml;
      };
    };
  };
}
