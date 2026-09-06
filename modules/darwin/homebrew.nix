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

    # Homebrew 6+ refuses to load formulae/casks from untrusted third-party
    # taps (HOMEBREW_REQUIRE_TAP_TRUST) — that aborts the whole switch.
    # Official homebrew/* taps are always trusted; mark everything else.
    taps = [
      { name = "1jehuang/jcode"; trusted = true; }
      { name = "antoniorodr/memo"; trusted = true; }
      { name = "cirruslabs/cli"; trusted = true; }
      { name = "docker/tap"; trusted = true; }
      { name = "gromgit/fuse"; trusted = true; }
      { name = "heroku/brew"; trusted = true; }
      "homebrew/services"
      { name = "hudochenkov/sshpass"; trusted = true; }
      { name = "kilo-org/tap"; trusted = true; }
      { name = "mongodb/brew"; trusted = true; }
      { name = "osx-cross/avr"; trusted = true; }
      { name = "oven-sh/bun"; trusted = true; }
      { name = "steipete/tap"; trusted = true; }
      { name = "teamookla/speedtest"; trusted = true; }
      { name = "tw93/tap"; trusted = true; }
      { name = "amir1376/tap"; trusted = true; }
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
      "tmux"
      "uv"
      "wasmtime"
      "wget"
      "hermes-agent"
    ];

    casks = [
      "basictex"
      "cloudflare-warp"
      "codex"
      "ghostty"
      "openvpn-connect"
      "raycast"
      "termius"
      "google-chrome"
      "figma"
      "anki"
      "spotify"
      "zed"
      "linear"
      "notion"
      "notion-calendar"
      "obsidian"
      "google-drive"
      "altserver"
      "maccy"
      "cap"
      "ab-download-manager"
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
