{ pkgs ? import <nixpkgs> {} }:

let
  cross = {
    config = "arm-none-eabi";
    libc = null;
  };

  crossPkgs = import <nixpkgs> { crossSystem = cross; };

  binutils-cross = crossPkgs.binutilsCross;

  gcc-cross = crossPkgs.gccCrossStageStatic;

  ghcEnv = pkgs.haskell.packages.ghc801.ghcWithPackages (p: with p; [
    shake
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
