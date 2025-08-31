# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, inputs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./cachix.nix
    ];

  boot.blacklistedKernelModules = [ "sp5100_tco" "elan_i2c" ];
  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.nur.repos.ionutnechita.linux_sunlight;
  boot.kernelParams = [
    "clocksource=tsc"
    "tsc=reliable"
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "udev.log_priority=3"
    "rd.systemd.show_status=auto"
    "irq_coalesce=minimal"
  ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 9;

  boot.plymouth = {
    enable = true;
    theme = "rog_2";
    themePackages = with pkgs; [
      (adi1090x-plymouth-themes.override {
        selected_themes = [ "rog_2" ];
      })
    ];
  };

  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.kernel.sysctl = {
    "kernel.sched_child_runs_first" = 1;
  };

  environment.systemPackages = with pkgs; [
    audacity
    btop
    cachix
    claude-code
    dig
    erlang
    elixir
    git
    gparted
    htop
    nodejs_22
    pkg-config
    python3
    remmina
    (texlive.combine {
      inherit (texlive) scheme-full;
    })
    unixtools.netstat
    usbutils
    vim
    wget
    windsurf
  ];

  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

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

  networking.hostName = "ionutnechita-arz2022";
  networking.networkmanager.enable = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
  nix.gc.automatic = true;
  nix.gc.dates = "18:40";
  nix.settings.trusted-users = [ "root" "ionutnechita" ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
  programs.firefox.enable = true;
  programs.virt-manager.enable = true;
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

  security.rtkit.enable = true;
  security.sudo.extraRules = [
    { users = [ "ionutnechita" ];
      commands = [
        { command = "ALL" ;
            options= [ "NOPASSWD" ];
        }
     ];
    }
  ];
  security.sudo.wheelNeedsPassword = true;

  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.flatpak.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  services.printing.enable = true;
  services.pulseaudio.enable = false;
  services.udev.packages = with pkgs; [
    usb-blaster-udev-rules
    ledger-udev-rules
  ];
  services.xserver.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  system.autoUpgrade.enable = true;
  system.stateVersion = "25.11";

  time.timeZone = "Europe/Bucharest";

  users.users.ionutnechita = {
     isNormalUser = true;
     description = "ionutnechita";
     shell = pkgs.zsh;
     subUidRanges = [{ startUid = 100000; count = 65536; }];
     subGidRanges = [{ startGid = 100000; count = 65536; }];
     extraGroups = [ "networkmanager" "wheel" "audio" "video" "dialout" "docker" "podman" "kvm" "rtkit" "render" "users" "libvirtd" "disk" ];
     packages = with pkgs; [
       firefox
       kdePackages.kate
       sshs
       thunderbird
     ];
     uid = 1000;
  };

  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.podman.enable = true;
}
