let 
  pkgs = import <nixpkgs> {};
  deriv = import ./default.nix {pkgs = pkgs;};
in 
  pkgs.callPackage (
    {stdenv, glibcLocales, lib}:
    # Mostly from nixpkgs/pkgs/development/haskell-modules/generic-builder.nix
    stdenv.mkDerivation {
      name = "interactive-${deriv.name}-${deriv.version}-environment";
      nativeBuildInputs = deriv.nativeBuildInputs;
      LANG = "en_US.UTF-8";
      LOCALE_ARCHIVE = lib.optionalString stdenv.isLinux "${glibcLocales}/lib/locale/locale-archive";
      shellHook = ''
        export NIX_GHC="${deriv.ghcEnv}/bin/ghc"
        export NIX_GHCPKG="${deriv.ghcEnv}/bin/ghc-pkg"
        export NIX_GHC_DOCDIR="${deriv.ghcEnv}/share/doc/ghc/html"
        export NIX_GHC_LIBDIR="${deriv.ghcEnv}/lib/${deriv.ghcEnv.name}"
      '';
    }
  ) {}
