# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# TODO FIRST : un fichier config pour tout les shortcuts, et config l'utilisateur
# TODO : eclipse : plantUML, sonarQube, JUnit
# TODO : quand maintiens VER MAJ + fleche gauche, droite, bas, haut, ça fait respectivement, debut de ligne, fin de ligne, page bas, page haut
# TODO : rajout obsidian, vscodium, vscode, btop, pinta, oracle virtualbox pour windows, 
# TODO : gérer les fichiers pour serveur minecraft
# TODO : gérer les versions de java, pour coder + javafx, et très récent pour serveur minecraft
# TODO : gérer tout les autres fichiers personnels pour transférer les fichiers entre les deux OS
# TODO : gérer droit utilisateur au niveau de la création, pas anatole

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Include modules
      ./modules/cooling.nix
      ./modules/graphics.nix
      ./modules/shortcuts.nix
      ./modules/monitoring.nix
      ./modules/kitty.nix
      ./modules/git_tools.nix
      ./modules/shell.nix
      ./modules/docker.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant. conflict with networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "fr";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  
  # NBFC activation (NoteBook Fan Control)
  # systemd.services.nbfc_service = {
  #   enable = true;
  #   description = "NoteBook Fan Control service";
  #   serviceConfig = {
  #     Type = "simple";
  #     ExecStart = "${pkgs.nbfc-linux}/bin/nbfc_service --config-file '/nix/store/...ton_config.json'";
  #     Restart = "always";
  #   };
  #   wantedBy = [ "multi-user.target" ];
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.anatole = {
    isNormalUser = true;
    description = "Anatole";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };
  
  # Allow the fans to restart without a password.
    security.sudo.extraRules = [{
      users = [ "anatole" ];
      commands = [{
        command = "/run/current-system/sw/bin/systemctl restart nbfc_service";
        options = [ "NOPASSWD" ];
      }];
    }];

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    # Basic tools
    gnome-text-editor
    pkgs.git
    pkgs.micro
    
    # Programmation Languages
    python3

    # Database
    postgresql

    # Some dependencies
    nbfc-linux
    wl-clipboard
    libnotify

  ];

  # Force micro to use system clipboard (wl-clipboard)
  environment.etc."micro/settings.json".text = ''
    {
        "clipboard": "external"
    }
  '';
  
  # Enable dconf to allow custom GNOME settings
  # programs.dconf.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # web diagnostic & cybersecurity tools
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;


  # Open ports in the firewall.
  # Autorize the default minecraft ports 25565
  networking.firewall.allowedTCPPorts = [ 25565 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
