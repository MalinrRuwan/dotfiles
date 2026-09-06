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
      "arping"
      "avrdude"
      "binwalk"
      "bkcrack"
      "block-goose-cli"
      "cairo"
      "cargo-zigbuild"
      "certbot"
      "cliclick"
      "cloudflare-wrangler"
      "cloudflared"
      "cmake"
      "cmatrix"
      "colima"
      "composer"
      "curl"
      "docker"
      "docker-buildx"
      "docker-compose"
      "docker-credential-helper"
      "exiftool"
      "ffmpeg@6"
      "forgecode"
      "freetds"
      "gh"
      "ghostscript"
      "git-delta"
      "git-filter-repo"
      "glib"
      "gnutls"
      "go"
      "gobuster"
      "grpcurl"
      "gstreamer"
      "harfbuzz"
      "hashcat"
      "helix"
      "herdr"
      "heroku"
      "htop"
      "jupyterlab"
      "k6"
      "llmfit"
      "maven"
      "mole"
      "mpv"
      "nano"
      "neofetch"
      "neovim"
      "netcat"
      "nmap"
      "node"
      "nvm"
      "ocrmypdf"
      "opencv"
      "pandoc"
      "php"
      "poppler"
      "portaudio"
      "protoc-gen-go"
      "pyqt"
      "python@3.12"
      "qemu"
      "redis"
      "rustscan"
      "sox"
      "speedtest-cli"
      "sshpass"
      "starship"
      "summarize"
      "tart"
      "tesseract"
      "texlive"
      "tmux"
      "unbound"
      "uv"
      "vtk"
      "wasmtime"
      "wget"
      "zbar"
      "zig"
    ];

    casks = [
      "android-platform-tools"
      "basictex"
      "blackhole-16ch"
      "burp-suite"
      "claude-code"
      "cloudflare-warp"
      "codex"
      "dbeaver-community"
      "flutter"
      "ghostty"
      "jdownloader"
      "monitorcontrol"
      "openvpn-connect"
      "openzfs"
      "packetsender"
      "raycast"
      "sbx"
      "tomatobar"
      "utm"
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
