{ pkgs }:

let
  vscodeWrapper = import ./vscode-wrapper.nix { inherit pkgs; };
  helpCommand = import ./help-command.nix { inherit pkgs; };
in
{
  packages = with pkgs; [
    # Shell and completions
    bashInteractive
    bash-completion

    # Build tools
    gcc
    pkg-config
    cmake

    # Version control and IDE
    git
    vscodeWrapper.package  # Use wrapper instead of plain vscode
    helpCommand.package    # Add help command

    # Nix tools for VS Code extensions
    nix
    nil  # Nix language server
    nixpkgs-fmt  # Nix formatter

    # Language support
    python3
    nodejs
    jq

    # System libraries
    glib
    glib.dev
    openssl
    openssl.dev

    # Development tools
    gdb
    valgrind
    lldb
  ];

  shellHook = ''
    # Source bash completion if available
    if [ -f ${pkgs.bash-completion}/etc/profile.d/bash_completion.sh ]; then
      source ${pkgs.bash-completion}/etc/profile.d/bash_completion.sh
    fi

    export PKG_CONFIG_PATH="${pkgs.glib.dev}/lib/pkgconfig:${pkgs.openssl.dev}/lib/pkgconfig:$PKG_CONFIG_PATH"

    # Ensure Nix tools are available for VS Code
    export PATH="${pkgs.nix}/bin:$PATH"

    # Show quick help on first entry
    if [ -z "$_DEV_HELP_SHOWN" ]; then
      export _DEV_HELP_SHOWN=1
      echo "💡 Type 'dev-help' for command reference"
    fi
  '';
}
