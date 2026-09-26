{ ... }:

let
  # Absolute path to this repo on disk. Must be a plain string (not a Nix
  # path literal like ./files/...) because a flake would resolve that inside
  # its read-only /nix/store copy.
  #
  # Every managed file below is linked with mkOutOfStoreSymlink: the symlink
  # in $HOME points at the file in this repo instead of the read-only store
  # copy, so editors and programs can write to it and edits take effect
  # immediately. No rebuild needed for file *contents* — only when the set
  # of managed files below changes (adding/removing entries).
  repo = "/private/etc/nix-darwin";
in

{
  # Home Manager via nix-darwin. Source of truth for dotfiles lives in ../../files/.
  #
  # Workflow:
  #   1. Edit files in files/dotfiles/ or files/config/<app>/, or edit the
  #      same file through its symlink in $HOME — it writes back to the repo.
  #   2. Commit the change.
  #   3. darwin-rebuild switch only when the managed file list below changes.
  #
  # Caveat: an app that saves its config by writing a temp file and renaming
  # it over the path replaces the symlink with a real file. That change then
  # lives only in $HOME, and the next switch moves it to *.hm-backup and
  # restores the repo version. `git config --global` is the main one to
  # watch; edit ~/.gitconfig with an editor (or edit the repo file) instead.
  #
  # Intentionally NOT managed (left in place):
  #   - ~/Library/Preferences/com.raycast*.plist: managed as symlinks,
  #     macOS cfprefsd replaced them with real files whenever Raycast saved,
  #     so every switch reverted in-app settings. Raycast owns them now.
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

    users.malindhamsara = { config, ... }: {
      home.stateVersion = "25.05";
      home.username = "malindhamsara";
      home.homeDirectory = "/Users/malindhamsara";

      programs.home-manager.enable = true;

      # --- shell / git / vim dotfiles (-> $HOME/.*) ---
      home.file = {
        ".zshrc".source = config.lib.file.mkOutOfStoreSymlink "${repo}/files/dotfiles/zshrc";
        ".zshenv".source = config.lib.file.mkOutOfStoreSymlink "${repo}/files/dotfiles/zshenv";
        ".gitconfig".source = config.lib.file.mkOutOfStoreSymlink "${repo}/files/dotfiles/gitconfig";
        ".vimrc".source = config.lib.file.mkOutOfStoreSymlink "${repo}/files/dotfiles/vimrc";

        # Ghostty keeps its config outside ~/.config on macOS.
        "Library/Application Support/com.mitchellh.ghostty/config".source =
          config.lib.file.mkOutOfStoreSymlink "${repo}/files/config/ghostty/config";
      };

      # --- ~/.config/* (XDG) ---
      xdg.configFile = {
        "starship/starship.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${repo}/files/config/starship/starship.toml";

        # Whole directory as one symlink: nvim-generated files (lazy-lock.json)
        # and in-place edits land back in the repo.
        "nvim".source =
          config.lib.file.mkOutOfStoreSymlink "${repo}/files/config/nvim";

        # Zed: only real settings, not conversation/prompt caches.
        "zed/settings.json".source =
          config.lib.file.mkOutOfStoreSymlink "${repo}/files/config/zed/settings.json";
        "zed/keymap.json".source =
          config.lib.file.mkOutOfStoreSymlink "${repo}/files/config/zed/keymap.json";

        # gh CLI: config only. hosts.yml (tokens) stays unmanaged in place.
        "gh/config.yml".source =
          config.lib.file.mkOutOfStoreSymlink "${repo}/files/config/gh/config.yml";
      };
    };
  };
}
