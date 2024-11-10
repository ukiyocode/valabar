{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      sys = "x86_64-linux";
    in
    {
      devShells.${sys}.default = with nixpkgs.legacyPackages.${sys}; mkShell {
        buildInputs = [
          gcc
          glib
          gobject-introspection
          gtk3
          libwnck
          meson
          ninja
          vala
          zsh
        ];
      };
    };
}
