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
    '';
  };

  # Set Zsh as default shell for user 'anatole'
  users.users.anatole.shell = pkgs.zsh;
}
