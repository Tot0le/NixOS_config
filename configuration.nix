# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let 
  fanScript = pkgs.writeShellScriptBin "fan_control.sh" ''
	  #!/bin/bash
	  
	  # --- CONFIGURATION ---
	  declare action="$1"
	  declare param="$2" # Peut être le "step" (pour + et -) ou la valeur cible (pour set)
	  declare -i HARD_LIMIT=100
	  declare STATE_FILE="/tmp/fan_speed_memory" 
	  
	  # Valeur par défaut du pas si non précisée (pour plus/moins)
	  declare -i step=''${param:-2}
	  
	  # --- AUTO-RÉPARATION DU SERVICE ---
	  if ! systemctl is-active --quiet nbfc_service
	  then
	      sudo systemctl restart nbfc_service
	      sleep 2
	  
	  fi
	  
	  declare -i current_speed
	  declare -i new_speed
	  
	  # --- LECTURE INTELLIGENTE ---
	  if [ -f "$STATE_FILE" ]
	  then
	      current_speed=$(cat "$STATE_FILE")
	  else
	      # Si pas de fichier, on lit le BIOS.
	      # Si le BIOS renvoie vide ou erreur, on considère 20.
	      current_speed=$(nbfc status | grep -m1 "Target" | sed 's/.*Target: \([0-9]*\).*/\1/')
	      if [ -z "$current_speed" ]; then current_speed=20; fi
	  fi
	  
	  # --- LOGIQUE ---
	  
	  if [ "$action" == "auto" ]
	  then
	      nbfc set -a
	      rm -f "$STATE_FILE"
	  
	  elif [ "$action" == "set" ]
	  then
	      # On récupère la valeur demandée (le 2ème argument)
	      target=''${param:-100} # Si oublies du chiffre, ça met 100 par sécurité
	  
	      if [ $target -gt $HARD_LIMIT ]; then target=$HARD_LIMIT; fi
	      if [ $target -lt 0 ]; then target=0; fi
	  
	      nbfc set -s $target
	      echo "$target" > "$STATE_FILE"
	  
	  elif [ "$action" == "plus" ]
	  then
	      # CORRECTION DU BUG : 
	      # Si on est en dessous de 30% (mode silencieux ou auto faible),
	      # un appui sur "+" nous propulse direct à 30% pour que ça serve à quelque chose.
	      if [ $current_speed -lt 30 ]; then
	          new_speed=30
	      else
	          new_speed=$((current_speed + step))
	      fi
	  
	      if [ $new_speed -gt $HARD_LIMIT ]; then new_speed=$HARD_LIMIT; fi
	  
	      nbfc set -s $new_speed
	      echo "$new_speed" > "$STATE_FILE"
	      
	  elif [ "$action" == "moins" ]
	  then
      	new_speed=$((current_speed - step))
      	if [ $new_speed -lt 0 ]; then new_speed=0; fi
  
        nbfc set -s $new_speed
        echo "$new_speed" > "$STATE_FILE"
        
    fi
    ''; # end FanScript

  # Color picker
  pickerScript = pkgs.writeShellScriptBin "pick_color.sh" ''
	    #!/bin/bash
	    
	    # Déclaration de variables
	    declare rawData
	    declare hexColor
	    
	    # Appel du service de capture natif de GNOME
	    rawData=$(gdbus call --session \
	        --dest org.gnome.Shell.Screenshot \
	        --object-path /org/gnome/Shell/Screenshot \
	        --method org.gnome.Shell.Screenshot.PickColor)
	    
	    if [ -n "$rawData" ]
	    then
	        # On exporte dans l'environnement pour eviter le conflit de quotes dans le shell
	        export RAW_DATA="$rawData"
	    
hexColor=$(python3 -c '
import os
import re

def convertToHex() -> str:
    rawInput: str = os.getenv("RAW_DATA", "")
    resultHex: str = ""
    match = re.search(r"\(([\d\.]+),\s*([\d\.]+),\s*([\d\.]+)\)", rawInput)
    if match:
        r: int = int(float(match.group(1)) * 255)
        g: int = int(float(match.group(2)) * 255)
        b: int = int(float(match.group(3)) * 255)
        resultHex = "#{:02x}{:02x}{:02x}".format(r, g, b)
    return resultHex

print(convertToHex())
')
	    
	        if [ -n "$hexColor" ]
	        then
	            echo -n "$hexColor" | wl-copy
	            notify-send "Color Picker" "Copié : $hexColor" -i color-select
	        fi
	    fi''; # end pick color script

in

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
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
  
  # Autoriser a relancer les ventilos sans password
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
    pkgs.kdePackages.kate
    pkgs.kitty
    pkgs.git
    pkgs.micro
    
    # Programmation Languages
    python3

	# Scripts
	fanScript
	pickerScript

    # Some dependencies
    nbfc-linux
    wl-clipboard
    libnotify

  ];

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
