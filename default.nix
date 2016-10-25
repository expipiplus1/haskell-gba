{ pkgs ? import <nixpkgs> {} }:

let
  cross = {
    config = "arm-none-eabi";
    libc = null;
  };

  crossPkgs = import <nixpkgs> { crossSystem = cross; };

  binutils-cross = crossPkgs.binutilsCross;

  gcc-cross = crossPkgs.gccCrossStageStatic;

  newlib = crossPkgs.callPackage (import ./newlib.nix) { config = cross.config; };

  haskellPackages = pkgs.haskell.packages.ghc801.override {
    overrides = self: super:
      let # A function to override the attributes passed to mkDerivation
          overrideAttrs = package: newAttrs: package.override (args: args // {
            mkDerivation = expr: args.mkDerivation (expr // newAttrs);
          });
          ivorySrc = pkgs.fetchFromGitHub{
            owner = "GaloisInc";
            repo = "ivory";
            rev = "79c37938d656250ac15799803f1d59bf9719485e";
            sha256 = "18kxg90zhzwd1mh37risbcwpini13gvajlrx3byhqadhsaxwy34j";
          };
      in { ivory = overrideAttrs super.ivory {
             src = ivorySrc + "/ivory";
           };
           ivory-opts = overrideAttrs super.ivory-opts {
             src = ivorySrc + "/ivory-opts";
           };
           ivory-backend-c = overrideAttrs super.ivory-backend-c {
             src = ivorySrc + "/ivory-backend-c";
           };
         };
  };

  ghcEnv = haskellPackages.ghcWithPackages (p: with p; [
    shake
    ivory
    ion
  ]);
in

pkgs.stdenv.mkDerivation rec {
  name = "gba";
  version = "0.0.1";

  src = builtins.filterSource (n: t: t != "unknown") ./.;

  buildInputs = [
    pkgs.clang
    gcc-cross
    binutils-cross
    ghcEnv
    newlib
  ];

  buildPhase = ''
    ${ghcEnv}/bin/runhaskell build.hs
  '';

  installPhase = ''
    mkdir -p $out
    cp make/hello.gba $out
  '';

  passthru = {
    ghcEnv = ghcEnv;
  };
}
