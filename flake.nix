{
  description = "Development environment for books and translations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        runtimeLibs = with pkgs; [
          stdenv.cc.cc.lib
          zlib
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            python3
            uv
            just
            git
            typst
            typstyle
            pandoc
            prettier
            fontconfig
          ] ++ runtimeLibs;

          shellHook = ''
            export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath runtimeLibs}:$LD_LIBRARY_PATH"
            export UV_PYTHON="${pkgs.python3}/bin/python"

            # We create workspace-relative symlinks in .fonts/ pointing to /nix/store fonts.
            # Typst and Tinymist (VS Code preview) enforce a project-root sandbox and forbid
            # reading files outside the workspace root (e.g. /nix/store/...).
            # However, Typst follows in-tree symlinks pointing outside the sandbox.
            # This avoids needing TYPST_ROOT="/" which breaks Tinymist preview in VS Code.
            if [ ! -d .fonts ]; then
              python3 ./generate_fonts.py
            fi
          '';
        };
      }
    );
}
