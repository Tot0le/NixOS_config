# /etc/nixos/users/features/kathara.nix
{ config, pkgs, lib, ... }:

let
  # Kathara package configuration with full dependency chain
  kathara = pkgs.python3Packages.buildPythonApplication rec {
    pname = "kathara";
    version = "3.8.3";
    format = "setuptools";
    
    src = pkgs.python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "84a2d3f8ea326cc1128e0a82f13019ed98d18155f8967824e72dc92e295eef84";
    };
    
    doCheck = false;
    
    # Required modules for terminal support and lab initialization
    propagatedBuildInputs = with pkgs.python3Packages; [
      docker
      packaging
      requests
      pyyaml
      python-dateutil
      rich
      binaryornot
      fs
      kubernetes
      libtmux
    ];

    # Map main script to bin and trigger Nix wrapper
    postInstall = ''
      mkdir -p $out/bin
      cp $out/lib/python${pkgs.python3.pythonVersion}/site-packages/kathara.py $out/bin/kathara
      chmod +x $out/bin/kathara
    '';
  };
in
{
  home.packages = [
    kathara
    pkgs.xterm
  ];

  # Initialize Kathara config with xterm to prevent OpenGL/EGL isolation crashes
  home.activation.initKathara = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -f "$HOME/.config/kathara.conf" ]; then
      $DRY_RUN_CMD mkdir -p "$HOME/.config"
      $DRY_RUN_CMD echo '{"terminal": "${pkgs.xterm}/bin/xterm"}' > "$HOME/.config/kathara.conf"
    fi
  '';

  # Force xterm to use modern fonts and readable colors
  xresources.properties = {
    "XTerm*renderFont" = true;
    "XTerm*faceName" = "Monospace";
    "XTerm*faceSize" = 11;
    "XTerm*background" = "black";
    "XTerm*foreground" = "white";
  };
}
