{ ... }:

{
  # Homebrew management (decoupled from nixmac, pure Nix lists).
  # Source of truth for taps / formulae / casks lives here.
  #
  # To add/remove: edit the lists below, then:
  #   darwin-rebuild build --flake .#Malins-MacBook-Pro
  #   darwin-rebuild switch --flake .#Malins-MacBook-Pro
  #
  # NOTE on `brews`: this lists only top-level `brew list --installed-on-request`
  # formulae (82). Dependencies (~300 more) are pulled automatically by brew.
  # Do NOT dump full `brew list` here.
  homebrew = {
    enable = true;

    taps = [
      "1jehuang/jcode"
      "antoniorodr/memo"
      "cirruslabs/cli"
      "docker/tap"
      "gromgit/fuse"
      "heroku/brew"
      "homebrew/services"
      "hudochenkov/sshpass"
      "kilo-org/tap"
      "mongodb/brew"
      "osx-cross/avr"
      "oven-sh/bun"
      "steipete/tap"
      "teamookla/speedtest"
      "tw93/tap"
    ];

    brews = [
      "aom"
      "certbot"
      "cloudflare-wrangler"
      "cmake"
      "colima"
      "curl"
      "docker"
      "docker-buildx"
      "docker-compose"
      "docker-credential-helper"
      "exiftool"
      "ffmpeg@6"
      "gh"
      "ghostscript"
      "git-delta"
      "git-filter-repo"
      "glib"
      "gnutls"
      "go"
      "gobuster"
      "gstreamer"
      "helix"
      "htop"
      "jupyterlab"
      "maven"
      "mole"
      "mpv"
      "neofetch"
      "neovim"
      "nmap"
      "node"
      "pandoc"
      "qemu"
      "rustscan"
      "speedtest-cli"
      "starship"
      "summarize"
      "tart"
      "tesseract"
      "texlive"
      "tmux"
      "uv"
      "wasmtime"
      "wget"
    ];

    casks = [
      "basictex"
      "cloudflare-warp"
      "codex"
      "ghostty"
      "openvpn-connect"
      "raycast"
    ];

    # Safe default: never uninstall anything you didn't declare yet.
    # Once `darwin-rebuild switch` is green, you can flip to "zap" to
    # garbage-collect brews/casks not listed here.
    # Allowed: "none" | "uninstall" | "zap"
    onActivation = {
      cleanup = "none";
      autoUpdate = true;
      # NOTE: `upgrade = true` runs `brew upgrade` on every switch and currently
      # fails on this machine (tomatobar is disabled upstream, burp-suite has a
      # broken /Applications entry). Keep false; upgrade manually with `brew upgrade`.
      upgrade = false;
    };
  };
}
