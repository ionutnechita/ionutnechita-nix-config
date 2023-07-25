# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
   baseconfig = { allowUnfree = true; };

   unstableTarball =
      fetchTarball
         https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;

   unstableNixTarball = (import (
      fetchTarball 
         "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz") { config = baseconfig; });

   nurTarball =
      fetchTarball
         https://github.com/nix-community/NUR/archive/master.tar.gz;
in

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  nix.settings.trusted-users = [ "root" "inechita" ];
  nix.settings.max-jobs = 10;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.cleanOnBoot = true;
  boot.consoleLogLevel = 0;
  boot.blacklistedKernelModules = [ "sp5100_tco" ];
  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.nur.repos.ionutnechita.linux_sunlight_mainline;
  boot.kernelParams = [
     "apparmor=1"
     "security=apparmor"
     "clocksource=tsc"
     "tsc=reliable"
     "cpuidle"
     "loglevel=0"
     "acpi_enforce_resources=lax"
     "vt.handoff=7"
     "nouveau.modeset=0"
     "systemd.show_status=1"
     "nvme_core.default_ps_max_latency_us=40"
     "quiet"
     "splash"
  ];

  networking.hostName = "inechita-nixos-vm1";

  networking.proxy.default = "http://proxy-chain.intel.com:912";
  networking.proxy.noProxy = "127.0.0.1,localhost";

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Bucharest";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ro_RO.UTF-8";
    LC_IDENTIFICATION = "ro_RO.UTF-8";
    LC_MEASUREMENT = "ro_RO.UTF-8";
    LC_MONETARY = "ro_RO.UTF-8";
    LC_NAME = "ro_RO.UTF-8";
    LC_NUMERIC = "ro_RO.UTF-8";
    LC_PAPER = "ro_RO.UTF-8";
    LC_TELEPHONE = "ro_RO.UTF-8";
    LC_TIME = "ro_RO.UTF-8";
  };

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  services.dbus.packages = with pkgs; [ gnome2.GConf ];
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.sudo.wheelNeedsPassword = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  security.sudo.extraRules = [
    { users = [ "inechita" ];
      commands = [
        { command = "ALL" ;
            options= [ "NOPASSWD" ];
        }
     ];
    }
  ];

  users.users.inechita = {
    isNormalUser = true;
    description = "inechita";
    shell = pkgs.zsh;
    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "dialout" "docker" "podman" "kvm" "rtkit" "render" "users" "libvirtd" "disk" ];
    packages = with pkgs; [
      firefox
      thunderbird
      sshs
    ];
    uid = 1000;
  };

  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
      nur = import nurTarball {
        inherit pkgs;
      };
      yandex-browser = unstableNixTarball.yandex-browser;
    };
    allowUnfree = true;
  };

  fonts.fonts = with pkgs; [
    fira-code
    fira
    cooper-hewitt
    ibm-plex
    fira-code-symbols
    powerline-fonts
  ];

  nixpkgs.overlays = [
    (self: super: {
      kakoune = super.wrapKakoune self.kakoune-unwrapped {
        configure = {
          plugins = with self.kakounePlugins; [
            parinfer-rust
          ];
        };
      };
    })
  ];

  environment = {
    shells = [
      "${pkgs.bash}/bin/bash"
      "${pkgs.zsh}/bin/zsh"
      "${pkgs.fish}/bin/fish"
    ];

    etc = with pkgs; {
      "jdk11".source = jdk11;
      "openjfx11".source = openjfx11;
      "containers/policy.json" = lib.mkDefault {
          mode="0644";
          text=''
            {
              "default": [
                {
                  "type": "insecureAcceptAnything"
                }
               ],
              "transports":
                {
                  "docker-daemon":
                    {
                      "": [{"type":"insecureAcceptAnything"}]
                    }
                }
            }
          '';
        };

      "containers/registries.conf" = lib.mkDefault {
          mode="0644";
          text=''
            [registries.search]
            registries = ['docker.io', 'quay.io']
          '';
        };
      };


    variables = {
      EDITOR = pkgs.lib.mkOverride 0 "nano";
      BROWSER = pkgs.lib.mkOverride 0 "yandex-browser";
      TERMINAL = pkgs.lib.mkOverride 0 "kitty";
    };

    systemPackages = with pkgs; [

     coreutils
     gitAndTools.gitFull
     man
     mkpasswd
     wget
     xorg.xkill
     ripgrep-all
     visidata
     youtube-dl
     chromedriver
     geckodriver
     pandoc
     jdk11
     openjfx11
     direnv
     emacs
     aspell
     aspellDicts.en
     aspellDicts.en-computers
     chezmoi
     entr
     modd
     devd
     notify-desktop
     xclip
     exercism
     kakoune
     unstable.kak-lsp
     unstable.kitty
     taskwarrior
     tasknc
     nnn
     nq
     fpp 
     rofi
     fff
     taskell
     trash-cli
     bat
     unstable.tre
     fzf
     apparix
     pazi
     exa
     skim
     jq
     yq-go
     unstable.ncurses
     unstable.tre-command
     unstable.tree-sitter
     surf

     nixpkgs-lint
     nixpkgs-fmt
     nixfmt

     unstable.podman
     unstable.buildah
     unstable.conmon
     unstable.runc
     unstable.slirp4netns
     unstable.fuse-overlayfs

     starship
     any-nix-shell
     unstable.nushell
     zsh
     zsh-autosuggestions
     nix-zsh-completions

     unstable.asciidoctorj
     graphviz
     compass
     pandoc
     ditaa

     chromium
     dbeaver
     slack
     fondo
     torrential
     vocal
     lollypop
     unetbootin
     vscodium
     gitg
     firefox
     unclutter
     pithos
     joplin-desktop
     virtmanager
     inkscape
     calibre

     gnome3.gnome-boxes
     gnome3.polari
     gnome3.dconf-editor
     gnome3.gnome-tweaks
     gnomeExtensions.impatience
     gnomeExtensions.dash-to-dock
     gnomeExtensions.dash-to-panel
     unstable.gnomeExtensions.tilingnome
     gnomeExtensions.system-monitor

     numix-cursor-theme
     bibata-cursors
     capitaine-cursors
     equilux-theme
     materia-theme
     mojave-gtk-theme
     nordic
     paper-gtk-theme
     paper-icon-theme
     papirus-icon-theme
     plata-theme
     sierra-gtk-theme

     clojure
     clj-kondo
     leiningen
     boot
     parinfer-rust
     unstable.clojure-lsp

     python310Full
     python310Packages.pip

     vim
     nano
     wget
     htop
     firefox
     kate
     thunderbird
     virt-manager
     tdesktop
     git
     vscode.fhs
     bmon
     btop
     yandex-browser
   ];
  };

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "sudo" ];
      theme = "linuxonly";
    };
  };

  programs.mtr.enable = true;
  programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
  };

  programs.fish.enable = true;
  programs.steam.enable = true;
  programs.command-not-found.enable = true;

  services.power-profiles-daemon.enable = false;
  services.tlp = {
     enable = true;
     settings = {
        START_CHARGE_THRESH_BAT0 = 60;
        STOP_CHARGE_THRESH_BAT0 = 80;
      };
  };

  services.acpid.enable = true;
  services.upower.enable = true;
  services.dbus.enable = true;
  services.xserver.libinput.enable = true;
  services.lorri.enable = true;
  services.flatpak.enable = true;
  services.tor.enable = true;
  services.openssh.enable = true;

  services.udev.packages = with pkgs; [
     usb-blaster-udev-rules
  ];

  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [ 22 ];
  networking.firewall.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  powerManagement.enable = true;

  nix.gc.automatic = true;
  nix.gc.dates = "18:40";
  system.autoUpgrade.enable = true;
  system.stateVersion = "23.11";
}
