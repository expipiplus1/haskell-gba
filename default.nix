{ pkgs ? import <nixpkgs> {} }:

let
  cross = {
    config = "arm-none-eabi";
    libc = "newlib";
  };

  crossPkgs = import <nixpkgs> {
    crossSystem = cross;
    config = {
      packageOverrides = pkgs: {
        libcCross = pkgs.forceNativeDrv (pkgs.callPackage ./newlib.nix { config = cross.config; });
        libiconv = pkgs.libiconv.overrideDerivation (attrs: {
          patchPhase = ''
            patch -p0 < ${(pkgs.fetchurl {
              url = "https://gist.githubusercontent.com/paulczar/5493708/raw/b8e40037af5c882b3395372093b78c42d6a7c06e/gistfile1.txt";
              sha256 = "09v25kc9sqpkm3y82c411f3l4mb252frgpavrcyr9bi3hlwirwk3";
            })}
          '';
        });
      };
    };
  };

  binutils-cross = crossPkgs.binutilsCross;

  gcc-cross = crossPkgs.gccCrossStageStatic;

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
    crossPkgs.gcc
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
