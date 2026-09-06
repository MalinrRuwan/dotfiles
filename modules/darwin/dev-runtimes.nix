{ ... }:

let
  userHome = "/Users/malinruwanpathirana";
in
{
  # Dev runtimes + their global packages.
  #
  # Design notes (learned the hard way):
  #   - node comes from homebrew.brews, but npm's prefix here is ~/.local
  #     (standalone-node era). Checks use explicit binary paths, so they work
  #     with either prefix and never flip between them.
  #   - bun and rustup are standalone installers (self-updating toolchains,
  #     pinned nightlies). A brew duplicate would shadow/fight them.
  # PATH handling: activation runs in one shared shell and every export
  # re-hashes command lookup. Prepending shadowed nix's GNU tools/bash with
  # macOS BSD ones and aborted home-manager's own linkGeneration (readlink -e,
  # find -printf, [[ -v ]]). So my dirs go LAST (append): system resolution
  # stays identical to a stock switch, while npm's `env node` shebang still
  # resolves. Tool *selection* (which npm/cargo) stays pinned via absolute
  # paths below, independent of PATH order.
  # Everything is guarded: a green switch re-run is a fast no-op.
  home-manager.users.malinruwanpathirana.home.activation = {
    devRuntimes = {
      after = [ "writeBoundary" ];
      before = [ ];
      data = ''
        export PATH="$PATH:${userHome}/.local/bin:${userHome}/.bun/bin:${userHome}/.cargo/bin:/opt/homebrew/bin"
        BUN_BIN="${userHome}/.bun/bin/bun"
        RUSTUP_BIN="${userHome}/.cargo/bin/rustup"

        # --- bun (standalone, ~/.bun) ---
        if [ ! -x "$BUN_BIN" ]; then
          echo "installing bun..."
          /usr/bin/curl -fsSL https://bun.sh/install | bash
        fi

        # --- rustup (standalone, ~/.rustup + ~/.cargo) ---
        if [ ! -x "$RUSTUP_BIN" ]; then
          echo "installing rustup..."
          /usr/bin/curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
            | sh -s -- -y --default-toolchain stable --profile default
        fi
        for tc in nightly 1.85 1.88 nightly-2026-07-05; do
          if ! "$RUSTUP_BIN" toolchain list 2>/dev/null | grep -q "^$tc-aarch64-apple-darwin"; then
            echo "installing rust toolchain $tc..."
            "$RUSTUP_BIN" toolchain install "$tc" --profile default
          fi
        done
      '';
    };

    devGlobals = {
      after = [ "devRuntimes" ];
      before = [ ];
      data = ''
        export PATH="$PATH:${userHome}/.local/bin:${userHome}/.bun/bin:${userHome}/.cargo/bin:/opt/homebrew/bin"
        NPM=""
        if [ -x "${userHome}/.local/bin/npm" ]; then
          NPM="${userHome}/.local/bin/npm"
        elif [ -x /opt/homebrew/bin/npm ]; then
          NPM=/opt/homebrew/bin/npm
        fi
        BUN_BIN="${userHome}/.bun/bin/bun"
        CARGO_BIN="${userHome}/.cargo/bin/cargo"

        # --- npm globals (opencode comes from the `opencode-ai` package) ---
        if [ -n "$NPM" ]; then
          for pkg in \
            @colbymchenry/codegraph \
            @earendil-works/pi-coding-agent \
            @opencode-ai/cli \
            command-code \
            opencode-ai \
          ; do
            if ! "$NPM" ls -g --depth=0 "$pkg" >/dev/null 2>&1; then
              echo "npm installing -g $pkg..."
              "$NPM" install -g "$pkg"
            fi
          done
        else
          echo "devGlobals: npm not found, skipping npm globals"
        fi

        # --- bun globals (none yet — add package names to this list) ---
        if [ -x "$BUN_BIN" ]; then
          for pkg in \
          ; do
            if [ ! -e "${userHome}/.bun/install/global/node_modules/$pkg" ]; then
              echo "bun adding -g $pkg..."
              "$BUN_BIN" add -g "$pkg"
            fi
          done
        else
          echo "devGlobals: bun not found, skipping bun globals"
        fi

        # --- cargo globals (`cargo install --list` is the source of truth) ---
        if [ -x "$CARGO_BIN" ]; then
          for crate in \
            create-tauri-app \
            mdbook \
            ripgrep \
            rustlings \
            typst-cli \
            wasm-bindgen-cli \
            wasm-pack \
            worker-build \
          ; do
            if ! "$CARGO_BIN" install --list 2>/dev/null | grep -q "^$crate v"; then
              echo "cargo installing $crate..."
              "$CARGO_BIN" install "$crate"
            fi
          done
          # NOTE: mdbook-trpl was installed via `cargo install --path` from a local
          # repo (~/Documents/repos/rust_book) that no longer exists — excluded
          # until that repo is back.
        else
          echo "devGlobals: cargo not found, skipping cargo globals"
        fi
      '';
    };
  };
}
