{ pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    # nativeBuildInputs is usually what you want -- tools you need to run
    nativeBuildInputs = with pkgs.buildPackages; [ 
      glib
      gobject-introspection
      gtk3
      libwnck
      vala
      cowsay
    ];
}
