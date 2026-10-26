# xrompf-dots

![Preview](setup.png)

<!-- Replace this line with the uploaded video URL from GitHub -->
https://github.com/user-attachments/assets/YOUR-VIDEO-ID

Base [Caelestia](https://github.com/caelestia-dots/shell) with some small changes, running the `linux-zen` kernel instead of the stock Linux kernel.

## Features

- Modded **infinite-desktop-v2** to work on Caelestia (buggy, but it works!)
- Custom **zsh config** with two themes for the ultimate terminal rice
- Tweaked some settings, and removed or remapped shortcuts so the plugins work together

> It looks simple, but debugging and tracking down paths took a lot longer than it seems lol.
**Known issue:** the toggleable infinite windows from infinite-desktop-v2 don't fully work yet.

## Installation (manual, automatic wizard coming soon)

### Dependencies
- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Caelestia](https://github.com/caelestia-dots/shell) (Hyprland recommended, other WMs may work)

### Dotfiles

| Copy this file from the repo | To here |
|---|---|
| `fishgreet.fish` | `~/.config/fish/functions/fish_greeting.fish` |
| `zsh config (with omz)/.zshrc` | `~/.zshrc` |
| `zsh config (with omz)/.p10k.zsh` | `~/.p10k.zsh` |
| `caelestia-config (pretty small).json` | `~/.config/caelestia/shell.json` |

Automatic config for astra-airlock:
`sudo astra-airlock -k hyprland`

### Plymouth (Limine)
Edit `/boot/EFI/BOOT/limine.conf` and add `rw quiet splash` to the kernel command line.

## Credits
- infinite-desktop-v2 by sarodcommits
- [Caelestia](https://github.com/caelestia-dots) by caelestia-dots
- [Hyprland](https://hyprland.org/)
- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh) by the ohmyzsh team
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) by romkatv
- [zsh](https://www.zsh.org/)
