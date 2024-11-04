{
  description = "Vala development environment with specified libraries and zsh shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
    forAllSystems = f: builtins.genAttrs supportedSystems f;
  in
  {
    devShells = forAllSystems (system:
      let pkgs = import nixpkgs { inherit system; };
      in
      {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            vala
            pkg-config
            glib
            gtk3
            libwnck3
          ];
          shell = pkgs.zsh;
        };
      });
  };
}
