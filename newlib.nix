{ stdenv, fetchurl, gccCrossStageStatic, config }:
stdenv.mkDerivation rec {
  name = "newlib-2.4.0.20160923";

  src = fetchurl {
    url = "ftp://sourceware.org/pub/newlib/${name}.tar.gz";
    sha256 = "1ak9m5dqy1vwccr2119da7bxbf17wh4cr0i5jvzxn3i6yhvil57f";
  };

  buildInputs = [ gccCrossStageStatic ];

  configurePhase = ''
    ./configure --prefix $out --host x86_64 --target ${config}
  '';

  installPhase = ''
    make install
    mv $out/${config}/* $out/
    rmdir $out/${config}
  '';
}
