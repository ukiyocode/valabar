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
        nativeBuildInputs = [ pipewire ];
        buildInputs = [
          pkg-config
          gcc
          vala
          glib
          meson
          ninja
          libwnck
          bamf
          librsvg
        ];
      };
    };
}
