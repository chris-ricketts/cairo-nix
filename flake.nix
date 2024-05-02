{
  description = "Cairo toolchain in nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { nixpkgs, flake-utils, rust-overlay, ... }:
    let
      overlay = import ./overlay.nix;
    in
    {
      overlays = {
        default = overlay;
      };

      templates = {
        default = {
          path = ./templates/simple;
          description = "A basic project using cairo-nix";
        };
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) overlay ];
        };
      in
      {
        formatter = pkgs.nixpkgs-fmt;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            cargo
            cairo-bin.stable.cairo
            cairo-bin.stable.scarb
          ];
        };

        packages = {
          default = pkgs.cairo-bin.stable.scarb;
          cairo = pkgs.cairo-bin.stable.cairo;
          scarb = pkgs.cairo-bin.stable.scarb;
          cairo-beta = pkgs.cairo-bin.beta.cairo;
          scarb-beta = pkgs.cairo-bin.beta.scarb;
        };
      });
}
