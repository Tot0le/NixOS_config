# /etc/nixos/users/features/zsh-shell.nix
{ pkgs, lib, ... }:

{
  home.packages = [
    pkgs.starship
    (pkgs.writeShellScriptBin "toggle_prompt" (builtins.readFile ../../scripts/toggle_prompt.sh))
  ];

  # Initialize prompt state to Starship by default
  home.activation.initPromptState = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -f "$HOME/.config/prompt-state" ]
    then
      $DRY_RUN_CMD echo "starship" > "$HOME/.config/prompt-state"
    fi
  '';

  # Starship Configuration (Minimal Catppuccin Aesthetic)
  xdg.configFile."starship.toml".text = ''
    add_newline = false
    format = "$character$directory "
    right_format = "$git_branch"
    
    [character]
    success_symbol = "[->](bold green)"
    error_symbol = "[->](bold red)"
    
    [directory]
    format = "[$path]($style)"
    style = "bold blue"
    truncation_length = 1
    
    [git_branch]
    format = "[$symbol$branch]($style)"
    symbol = " "
    style = "bold white"
  '';

  # Core Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      declare -x ZSH_AUTOSUGGEST_HISTORY_IGNORE="*git commit*|*git clone*"
      
      # Trap SIGUSR2 to cleanly restart the shell with the new prompt
      TRAPUSR2() {
          echo ""
          if [ "$(cat ~/.config/prompt-state 2>/dev/null)" = "starship" ]
          then
              echo "Switched to Starship"
          else
              echo "Switched to Oh-My-Zsh"
          fi
          exec zsh
      }

      # Load Starship dynamically based on state
      if [ "$(cat ~/.config/prompt-state 2>/dev/null)" = "starship" ]
      then
          eval "$(starship init zsh)"
      fi
    '';

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" ];
    };
  };
}
