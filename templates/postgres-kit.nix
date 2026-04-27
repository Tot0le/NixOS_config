{ pkgs ? import <nixpkgs> {} }:

let
  # Fetching the universal "Database Client" (cweijan)
  databaseClient = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        name = "vscode-mysql-client2"; 
        publisher = "cweijan";
        version = "8.4.5"; 
        sha256 = "sha256-ypb0TeG5vVEeQIfEUfXYa3VTmP6Dqg7dQispajTBP94=";
      };
    };

  customVSCodium = pkgs.vscode-with-extensions.override {
    vscode = pkgs.vscodium;
    vscodeExtensions = [
      pkgs.vscode-extensions.ms-ceintl.vscode-language-pack-fr
      databaseClient
    ];
  };
in
pkgs.mkShell {
  buildInputs = [
    pkgs.postgresql_16
    customVSCodium
  ];

  shellHook = ''
      echo "--- PostgreSQL Dev Kit (Universal) Loaded ---"
      
      export PGDATA="$PWD/.db"
      
      # FIX: Force the socket and lock files to stay inside your project folder
      export PGHOST="$PGDATA" 
      
      if [ ! -d "$PGDATA" ]
      then
          initdb "$PGDATA"
      fi
  
      echo "Commands:"
      echo "  1. Start server:  pg_ctl start -l logfile"
      echo "  2. Open editor:    codium ."
      echo "  3. Stop server:   pg_ctl stop"
      echo ""
      echo "Use the Database icon in the VSCodium sidebar to connect."
    '';
}
