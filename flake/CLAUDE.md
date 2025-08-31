# NixOS Configuration Documentation

This repository contains a NixOS configuration for the `ionutnechita-arz2022` system. This is a flake-based configuration that leverages modern NixOS practices for system management.

## File Structure Overview

### Core Configuration Files

#### `configuration.nix`
The main system configuration file containing:
- **Hardware Support**: NVIDIA graphics configuration with beta drivers
- **Boot Configuration**: Uses systemd-boot with custom Sunlight kernel and Plymouth boot splash
- **System Packages**: Essential tools including development utilities (git, nodejs_22, claude-code)
- **Desktop Environment**: KDE Plasma 6 with SDDM display manager
- **Audio**: PipeWire configuration with ALSA, PulseAudio, and JACK support
- **Virtualization**: Docker, Podman, and libvirtd support
- **User Configuration**: Primary user with extensive group memberships for development

Key features:
- Custom kernel from `nur.repos.ionutnechita.linux_sunlight`
- NVIDIA proprietary drivers with beta package
- Plymouth boot splash with "rog_2" theme (ASUS-specific)
- Silent boot configuration with 9-second bootloader timeout
- Development-focused package selection
- Romanian locale with English as default

#### `hardware-configuration.nix`
Auto-generated hardware configuration (do not modify manually):
- **Storage**: BTRFS root filesystem with F2FS home partition
- **Boot**: UEFI with systemd-boot
- **Hardware**: AMD CPU with KVM support, NVIDIA GPU
- **Modules**: NVME, USB, and storage kernel modules

File systems:
- Root: `/dev/disk/by-uuid/7439235e-d4fc-4f0c-9185-33b9c34ac999` (BTRFS with @subvol)
- Boot: `/dev/disk/by-uuid/AFAE-984C` (VFAT)
- Home: `/dev/disk/by-uuid/fd1bd083-ada7-4a93-ad66-0458516cf8b4` (F2FS)
- Swap: `/dev/disk/by-uuid/6c20a5cc-046d-4775-b92a-7887d6b7c892`

#### `flake.nix`
Modern NixOS flake configuration:
- **Inputs**: nixpkgs (unstable channel) and NUR (Nix User Repository)
- **System**: Configured for x86_64-linux
- **Modules**: Integrates all configuration files
- **NUR Integration**: Provides access to community packages via overlay

The flake enables reproducible builds and easy system updates.

#### `flake.lock`
Lock file containing exact versions of all flake inputs:
- **nixpkgs**: Locked to specific unstable commit for reproducibility
- **NUR**: Locked to specific community repository state
- **Version**: Flake schema version 7

### Caching Configuration

#### `cachix.nix`
Dynamic Cachix cache loader:
- **Auto-import**: Automatically imports all `.nix` files from `cachix/` directory
- **Substituters**: Configured with cache.nixos.org as fallback
- **Modular**: Allows easy addition of new caches

#### `cachix/ionutnechita.nix`
Personal Cachix binary cache configuration:
- **Cache URL**: `https://ionutnechita.cachix.org`
- **Public Key**: `ionutnechita.cachix.org-1:7w9kLkHFYVBe6pG342q2tI3/JjCFlhGivb0prImq1gI=`
- **Purpose**: Speeds up builds by providing pre-compiled packages from personal cache

## System Capabilities

### Development Environment
- **Languages**: Node.js 22, with shell support for various languages via nixpkgs
- **Tools**: Git, vim, development utilities
- **IDE**: Claude Code integrated
- **Containers**: Docker and Podman support

### Graphics & Gaming
- **GPU**: NVIDIA RTX 3060 with proprietary beta drivers
- **Desktop**: KDE Plasma 6 with modern Wayland support
- **Graphics Stack**: Hardware acceleration enabled

### Multimedia
- **Audio**: PipeWire with full ALSA/PulseAudio/JACK compatibility
- **Applications**: Audacity for audio editing, Firefox for web browsing

### Virtualization
- **Type 1**: KVM with libvirtd and virt-manager
- **Containers**: Docker and Podman with rootless support
- **Management**: Full virtualization stack for development

## Building and Updating

### Initial Setup
```bash
sudo nixos-rebuild switch --flake .
```

### Updates
```bash
nix flake update  # Update flake.lock
sudo nixos-rebuild switch --flake .
```

### Cache Usage
The system is configured to use the personal Cachix cache which should speed up builds significantly by providing pre-built packages.

## Development Workflow

1. **Modify Configuration**: Edit `configuration.nix` for system changes
2. **Add Packages**: Add to `environment.systemPackages` or user packages
3. **Test Changes**: Use `nixos-rebuild test` for temporary changes
4. **Apply Changes**: Use `nixos-rebuild switch` to make changes permanent
5. **Version Control**: All changes are tracked via Git

## Security Considerations

- **Sudo Access**: User has passwordless sudo (configured for development convenience)
- **Firewall**: Default NixOS firewall enabled
- **Auto-updates**: System auto-upgrade enabled
- **Binary Caches**: Uses trusted caches with verified signatures

## System Maintenance

- **Garbage Collection**: Automatic at 18:40 daily
- **State Version**: 25.11 (ensure compatibility when updating)
- **Logs**: Available via journalctl
- **Monitoring**: htop and btop available for system monitoring

This configuration provides a robust, reproducible development environment optimized for modern workflows while maintaining system stability through NixOS's declarative configuration management.