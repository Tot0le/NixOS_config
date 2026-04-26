{ pkgs, ... }:

let
  # Import user secrets
  userSecrets = import ../secrets.nix;
  
  # Script to securely copy the GitHub token
  copyGitToken = pkgs.writeShellScriptBin "copyGitToken" ''
    #!/bin/bash
    
    # Initialize variables
    declare secretPass="${userSecrets.apiPassword}"
    declare myToken="${userSecrets.gitHubToken}"
    declare inputPass=""
    declare messageResult=""

    # Prompt for password securely
    echo -n "Enter access code: "
    read -s inputPass
    echo ""

    # Verify password and copy token
    if [[ "$inputPass" == "$secretPass" ]]
    then
        echo -n "$myToken" | ${pkgs.wl-clipboard}/bin/wl-copy
        messageResult="Token successfully copied to clipboard."
        ${pkgs.libnotify}/bin/notify-send "GitHub" "$messageResult" -i dialog-password
    else
        messageResult="Invalid code. Access denied."
    fi

    echo "$messageResult"
  '';
in
{
  environment.systemPackages = [
    copyGitToken
  ];
}
