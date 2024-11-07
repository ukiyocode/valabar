{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/92d295f588631b0db2da509f381b4fb1e74173c5";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      devShells.${system}.default = with pkgs; mkShell {
        buildInputs = [
          glib
          gobject-introspection
          gtk3
          libwnck
          vala
          zsh
        ];
        /*shellHook =
        ''
          exec zsh
        '';*/
      };
    };
}
