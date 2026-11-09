# Setting up a new machine

Manual steps for bringing up **michaela** (laptop, `aurora-michaela`) or
**melisandre** (`aurora-melisandre`) from scratch.

Everything that can be built into the image lives in the recipes. The steps
below are only the ones that can't: interactive logins, secrets,
per-user/runtime state, and installing the image itself. If you find yourself
doing something by hand that *could* go in the recipe, put it in the recipe
instead and drop it from this list.

Steps marked **(michaela)** or **(melisandre)** apply to that machine only;
everything else applies to both.

## 1. Install Aurora

Install the stock Aurora ISO matching the image's base, and create user
`aplancar` during install:

- **(michaela)** `aurora-dx-nvidia-open`
- **(melisandre)** `aurora-dx` (Intel iGPU only, no NVIDIA)

## 2. Rebase onto the custom image

Replace `<image>` with `aurora-michaela` or `aurora-melisandre`.

1. Go to the unsigned image first. This installs the signing policy and keys:
   ```
   sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/aplancar/<image>:latest
   systemctl reboot
   ```
2. Then switch to the signed image:
   ```
   sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/aplancar/<image>:latest
   systemctl reboot
   ```

From then on, apply new builds with `sudo bootc upgrade` and reboot.
Check the result with `bootc status` (as root) or `rpm-ostree status`.

**(michaela) Secure Boot:** if it's enabled, enroll the NVIDIA kmod signing
key. When prompted at the next boot (MOK manager), enter `universalblue`:
```
ujust enroll-secure-boot-key
```

## 3. User account state

The image can create groups and set defaults for *new* users, but your user
was created by the installer before the rebase. Adjust it by hand:

- **Default shell.** `set-default-shell.sh` only covers root and future users:
  ```
  sudo usermod -s /usr/bin/zsh aplancar
  ```
- **`nordvpn` group.** The group is created by `sysusers.d`, but membership is
  per-user. Without it, the `nordvpn` CLI can't talk to nordvpnd:
  ```
  sudo usermod -aG nordvpn aplancar
  ```
- **Developer groups** (docker, incus-admin, libvirt):
  ```
  ujust dx-group
  ```

Log out and back in, or reboot, for the group changes to take effect.

## 4. NordVPN (login + settings)

Account login and settings are nordvpnd runtime state in `/var/lib/nordvpn`,
so they can't be baked into the image.

```
nordvpn login             # opens browser
nordvpn set autoconnect on
nordvpn connect
```

You don't need to add the Tailscale allowlist entries by hand.
`nordvpn-tailscale-allowlist.service` adds them at boot. To verify after a
reboot:

```
systemctl status nordvpn-tailscale-allowlist
nordvpn settings | grep -A4 -i allowlist   # 100.64.0.0/10, 41641/udp
```

## 5. Tailscale (login)

The daemon ships enabled in Aurora. Joining the tailnet is an interactive
login that persists across reboots:

```
sudo tailscale up
tailscale status
```

## 6. CLI tools (Homebrew)

`gh`, `starship`, and the other CLI tools come from Aurora's brew setup, not
the image:

```
ujust aurora-cli
gh auth login
```

## 7. SSH key + GitHub

```
ssh-keygen -t ed25519
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(hostname)"
```

**(melisandre)** sshd is enabled by the image. To let michaela in, add
michaela's public key to melisandre's `~/.ssh/authorized_keys`:
```
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo '<contents of michaela:~/.ssh/id_ed25519.pub>' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

Then test from michaela, with NordVPN connected on both machines:
```
tailscale ping melisandre && ssh aplancar@melisandre
```

## 8. Dotfiles (bare repo)

```
git clone --bare git@github.com:aplancar/dotfiles.git ~/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
dotfiles config status.showUntrackedFiles no
cd ~ && dotfiles checkout
```

`checkout` refuses to overwrite existing files, such as the `.zshrc` the image
puts in `/etc/skel`. Move those aside and run `checkout` again:
```
mkdir -p ~/.dotfiles-backup
mv ~/.zshrc ~/.dotfiles-backup/
dotfiles checkout
```

## 9. This repo (michaela, or wherever you edit the recipes)

```
mkdir -p ~/git && git clone git@github.com:aplancar/aurora-aplancar.git ~/git/aurora-aplancar
```

`cosign.key` is gitignored and **not** recoverable from GitHub. CI only needs
the `SIGNING_SECRET` secret, so builds keep working without it, but you need
it locally to re-set that secret.

- **Restore from backup:** copy it to `~/git/aurora-aplancar/cosign.key`.
- **If it's lost:** generate a new pair and update both secrets. Every
  machine then has to redo the unsigned → signed rebase in step 2 to pick up
  the new `cosign.pub`.
  ```
  cosign generate-key-pair
  gh secret set SIGNING_SECRET < cosign.key
  gh secret set SIGNING_SECRET --app dependabot < cosign.key
  ```

## Not yet in the recipe

`org.mozilla.thunderbird_esr` is installed on michaela but isn't in the recipe
or Aurora's default flatpak set. It was installed before this repo existed.
Either add it to `default-flatpaks` or uninstall it.
