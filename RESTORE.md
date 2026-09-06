# Restore runbook — from factory reset to working Mac

Source of truth: this repo (`dotfiles-new`, private).
Tested on: Apple Silicon, macOS + Determinate Nix + nix-darwin.

## Part 0 — BEFORE you wipe (do all of these)

- [ ] `gpg --export-secret-keys > ~/identity-backup/staging/gpg-secret.asc` — confirm file is NOT 0 bytes (proves you know your GPG passphrase; without it the backup is useless)
- [ ] Finish encryption: `tar` + `openssl enc` the `~/identity-backup/staging` dir (see "Identity backup" below), copy `*.tar.gz.enc` + passphrase to an **external drive**, and put the passphrase in your **password manager**
- [ ] Commit/push dirty repos: `gov_lk_web_auditor` (17 files), `worktable` (19), `skyTraveller` (2)
- [ ] Back up `~/Documents/repos/chat-agent` (not a git repo — exists only on disk)
- [ ] Full **Time Machine** backup to external drive (safety net for Documents, photos, app data)
- [ ] Create a GitHub **fine-grained PAT** (contents: read on `dotfiles-new`) — needed to clone on the fresh Mac. Store in password manager.
- [ ] Raycast: Settings → Advanced → Export. UTM: export VMs. Note any Postgres/Mongo/Redis data worth dumping.

## Part 1 — Fresh macOS

1. Erase All Content and Settings → go through Setup Assistant.
2. Create user **`malinruwanpathirana`** (must match `system.primaryUser` in `flake.nix`).
3. Set Computer Name to `Malins-MacBook-Pro` (System Settings → General → About). The flake enforces this anyway.
4. `xcode-select --install` (gives you git).

## Part 2 — Nix + first switch

```bash
# 1. Determinate Nix (required — this flake sets nix.enable = false)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
# open a NEW terminal after install

# 2. Clone (private repo — use the PAT from Part 0)
sudo git clone https://<PAT>@github.com/MalinrRuwan/dotfiles-new.git /private/etc/nix-darwin
sudo chown -R $(whoami):staff /private/etc/nix-darwin
cd /private/etc/nix-darwin

# 3. Bootstrap nix-darwin, then switch (downloads GBs: texlive, basictex, flutter… be on power + wifi)
nix run nix-darwin -- switch --flake .#Malins-MacBook-Pro
sudo darwin-rebuild switch --flake .#Malins-MacBook-Pro
```

No-PAT fallback: download the repo ZIP from github.com in a browser, unzip to `/private/etc/nix-darwin`, then run step 3. Re-attach git later with `gh repo clone` + move `.git` over.

## Part 3 — Identity backup restore

```bash
cd ~/identity-backup
openssl enc -d -aes-256-cbc -pbkdf2 -in <bundle>.tar.gz.enc -out restore.tar.gz -pass file:<passphrase>.txt
tar xzf restore.tar.gz   # contains staging/{ssh,gpg-*}

# SSH
cp -r staging/ssh ~/.ssh && chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_* ~/.ssh/key3.pem 2>/dev/null; chmod 644 ~/.ssh/*.pub
ssh-add -l  # sanity check

# GPG (will prompt for your key passphrase)
gpg --import staging/gpg-public-all.asc
gpg --import staging/gpg-secret.asc
gpg --import-ownertrust staging/gpg-ownertrust.txt
gpg --list-secret-keys --keyid-format LONG
echo "test" | gpg --clearsign --local-user hello@malindhamsara.dev -o /dev/null -  # signing works?
```

## Part 4 — Re-authenticate (never backed up by design)

```bash
gh auth login            # ~/.config/gh/hosts.yml tokens were excluded
git config --global credential.helper store   # recreates ~/.git-credentials on first push
```
- Raycast → Import the file from Part 0. UTM → import VMs.
- `brew services start redis` / `php` if you used them (see `brew info` hints).
- Re-run `darwin-rebuild switch` once at the end; everything should be a no-op.

## Part 5 — Known issues

- **`tomatobar` is disabled upstream** — fresh `brew install` fails. Either remove it from `modules/darwin/homebrew.nix` or leave the cask entry (installed-but-frozen).
- `homebrew.onActivation.upgrade = false` is intentional — run `brew upgrade` manually so one broken formula can't fail a whole switch.
- sops-nix is wired but `.sops.yaml` still has the placeholder key — secrets flow is not live; don't expect secret files to appear.
