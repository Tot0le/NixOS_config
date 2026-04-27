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
    
    # Define local data directory
    export PGDATA="$PWD/.db"
    
    # Force the socket and lock files to stay inside your project folder
    export PGHOST="$PGDATA" 
    
    if [ ! -d "$PGDATA" ]
    then
        initdb "$PGDATA"
        # Force the server socket to stay in the local project
        echo "unix_socket_directories = '$PGDATA'" >> "$PGDATA/postgresql.conf"
    fi

    # Automatically stop the server when exiting (Ctrl+D or exit) if it is running
    trap 'if [ -f "$PGDATA/postmaster.pid" ]
    then
        echo "--- Stopping PostgreSQL ---"
        pg_ctl stop
    fi' EXIT

    echo "Commands:"
    echo "  1. Start server:  pg_ctl start -l logfile"
    echo "  2. Open editor:   codium ."
    echo "  3. Stop server:   pg_ctl stop (or simply use Ctrl+D)"
    echo ""
    echo "Connection details for VSCodium Database Client:"
    echo "  - Host:      127.0.0.1"
    echo "  - Port:      5432"
    echo "  - Username:  $USER"
    echo "  - Password:  <leave empty>"
    echo "  - Database:  postgres"
  '';
}
