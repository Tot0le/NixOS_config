{ pkgs, ... }:

{
  # Zsh system-wide configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    # Oh My Zsh management (replacing zshrc.conf)
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };

    interactiveShellInit = ''
      # History search (Up/Down arrows)
      bindkey '^[[A' history-beginning-search-backward
      bindkey '^[[B' history-beginning-search-forward

      # Add your custom aliases here if you had any
      # alias ll='ls -al'

      # --- Development environment shortcuts ---
      
      # Launch the database environment on the fly
      alias dev-db="nix-shell /etc/nixos/templates/postgres-kit.nix"
      
      # Initialize, edit, and launch a permanent database project in the current directory
      setup-db() {
         if [ ! -f "shell.nix" ]
         then
           cp /etc/nixos/templates/postgres-kit.nix ./shell.nix
         fi
         
         # Open the file for editing
         nano shell.nix
         
         # Launch the environment once the editor is closed
         nix-shell
       }
      
    '';
  };

  # Set Zsh as default shell for user 'anatole'
  users.users.anatole.shell = pkgs.zsh;
}
