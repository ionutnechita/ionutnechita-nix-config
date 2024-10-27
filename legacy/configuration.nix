# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
   unstableNixTarball =
     fetchTarball
         https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz;

   unstableSmallNixTarball =
     fetchTarball
         https://channels.nixos.org/nixos-unstable-small/nixexprs.tar.xz;

   unstableYandexGit =
     pkgs.fetchFromGitHub {
         owner = "ionutnechita";
         repo = "nixos-nixpkgs";
         rev = "local/yandex-browser-update-2024Q4";
         hash = "sha256-jkXcdURnGOJXtDIJXbFgAyTg3+xEsrX6dhDEWSC6WdA=";
     };

   unstableNurTarball =
     fetchTarball
         https://github.com/nix-community/NUR/archive/master.tar.gz;
in
{
  imports =
    [
     ./hardware-configuration.nix
     ./cachix.nix
    ];

  nix.settings.trusted-users = [ "root" "ionutnechita" ];
  nix.settings.max-jobs = 10;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.cleanOnBoot = true;
  boot.consoleLogLevel = 0;
  boot.kernel.sysctl."kernel.printk" = "0 0 0 0";
  boot.initrd.verbose = false;
  boot.blacklistedKernelModules = [ "sp5100_tco" "elan_i2c" "btrtl" "btmtk" "btintel" "btbcm" "btusb" ];
  boot.kernelPackages = pkgs.linuxPackagesFor pkgs.nur.repos.ionutnechita.linux_sunlight;
  boot.kernelParams = [
     "amd_pstate=active"
     "apparmor=1"
     "security=apparmor"
     "clocksource=tsc"
     "tsc=reliable"
     "cpuidle"
     "loglevel=0"
     "acpi_enforce_resources=lax"
     "vt.handoff=7"
     "systemd.show_status=0"
     "quiet"
     "splash"
     "boot.shell_on_fail"
     "rd.systemd.show_status=0"
     "rd.udev.log_level=3"
     "udev.log_priority=3"
  ];

  boot.plymouth =  {
     enable = true;
     theme = "rog_2";
     themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
           selected_themes = [ "rog_2" ];
        })
     ];
  };

  networking.hostName = "ionutnechita-arz2022";

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
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = {
     layout = "us";
     variant = "";
  };
  console.useXkbConfig = true;

  services.dbus.packages = with pkgs; [ gnome2.GConf ];

  services.printing.enable = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
     enable = true;
     alsa.enable = true;
     alsa.support32Bit = true;
     pulse.enable = true;
     jack.enable = true;
  };

  security.sudo.wheelNeedsPassword = true;
  security.sudo.extraRules = [
    { users = [ "ionutnechita" ];
      commands = [
        { command = "ALL" ;
            options= [ "NOPASSWD" ];
        }
     ];
    }
  ];
  users.users.ionutnechita = {
     isNormalUser = true;
     description = "ionutnechita";
     shell = pkgs.zsh;
     subUidRanges = [{ startUid = 100000; count = 65536; }];
     subGidRanges = [{ startGid = 100000; count = 65536; }];
     extraGroups = [ "networkmanager" "wheel" "audio" "video" "dialout" "docker" "podman" "kvm" "rtkit" "render" "users" "libvirtd" "disk" ];
     packages = with pkgs; [
       unstable.firefox
       unstable.kdePackages.kate
       unstable.thunderbird
       unstable.sshs
     ];
     uid = 1000;
  };

  users.extraGroups.vboxusers.members = [ "ionutnechita" ];

  programs.firefox.enable = true;

  nixpkgs.config = {
     packageOverrides = pkgs: {
       unstable = import unstableNixTarball {
         config = config.nixpkgs.config;
       };
       unstableSmall = import unstableSmallNixTarball {
         config = config.nixpkgs.config;
       };
       nur = import unstableNurTarball {
         inherit pkgs;
       };
       yandex-unstable = import unstableYandexGit {
         config = config.nixpkgs.config;
       };
     };
     permittedInsecurePackages = [
       "yandex-browser-stable-24.12.1.712-1"
       "yandex-browser-beta-24.12.1.704-1"
     ];
     allowUnfree = true;
  };

  fonts.packages = with pkgs; [
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

  environment.shells = with pkgs; [
     "${bash}/bin/bash"
     "${zsh}/bin/zsh"
  ];

  environment.etc = with pkgs; {
     "jdk17".source = jdk17;
     "openjfx17".source = openjfx17;
     "containers/policy.json" = lib.mkDefault {
         mode="0644";
         text=''
            {
               "default":
                  [
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

  environment.variables = {
     EDITOR = pkgs.lib.mkOverride 0 "nano";
     BROWSER = pkgs.lib.mkOverride 0 "yandex-browser-stable";
     TERMINAL = pkgs.lib.mkOverride 0 "kitty";
  };

  environment.systemPackages = with pkgs; [
   unstableSmall.azure-functions-core-tools
   unstableSmall.azurite
   bmon
   brave
   btop
   cachix
   cargo
   coreutils
   direnv
   discord-ptb
   file
   gcc
   go
   google-chrome
   htop
   hunspell
   hunspellDicts.ro_RO
   iftop
   jdk17
   jq
   k9s
   kakoune
   killall
   kind
   kitty
   kubectl
   libcap
   libreoffice-qt6
   man
   mongodb-compass
   nixfmt-classic
   nixpkgs-fmt
   nixpkgs-lint
   nix-zsh-completions
   nmap
   nodejs_20
   openjfx17
   pciutils
   postman
   python312Full
   python312Packages.pip
   qbittorrent
   rar
   rustup
   unrar
   unrar-wrapper
   unstableSmall.git
   unstableSmall.git-repo
   vim
   vlc
   vscode.fhs
   wget
   whatsapp-for-linux
   yandex-unstable.yandex-browser
   yandex-unstable.yandex-browser-beta
   yarn
   zsh
   zsh-autosuggestions
  ];

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

  programs.appimage = {
   enable = true;
   binfmt = true;
  };

  services.power-profiles-daemon.enable = false;
  services.tlp = {
     enable = true;
     settings = {
        START_CHARGE_THRESH_BAT0 = 60;
        STOP_CHARGE_THRESH_BAT0 = 80;
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_DRIVER_OPMODE_ON_AC = "guided";
        CPU_DRIVER_OPMODE_ON_BAT = "active";
        CPU_SCALING_GOVERNOR_ON_AC = "ondemand";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_performance";
        CPU_SCALING_MIN_FREQ_ON_AC = 600000;
        CPU_SCALING_MAX_FREQ_ON_AC = 4600000;
        CPU_SCALING_MIN_FREQ_ON_BAT = 500000;
        CPU_SCALING_MAX_FREQ_ON_BAT = 1900000;
        CPU_MIN_PERF_ON_AC = 20;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 40;
        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersupersave";
        RUNTIME_PM_ON_AC = "on";
        RUNTIME_PM_ON_BAT = "on";
     };
  };
  services.acpid.enable = true;
  services.upower.enable = true;
  services.dbus.enable = true;
  services.libinput.enable = true;
  services.lorri.enable = true;
  services.flatpak.enable = true;
  services.tor.enable = true;
  services.openssh = {
   enable = true;
   settings = {
     PermitRootLogin = "no";
     PasswordAuthentication = true;
   };
  };
  services.mongodb.enable = true;
  services.mongodb.package = pkgs.mongodb-ce;

  services.udev.packages = with pkgs; [
     usb-blaster-udev-rules
     ledger-udev-rules
  ];

  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [ 22 ];
  networking.firewall.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.podman.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  programs.virt-manager.enable = true;

  powerManagement.enable = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nix.gc.automatic = true;
  nix.gc.dates = "18:40";
  system.autoUpgrade.enable = true;
  system.stateVersion = "24.11";
}
