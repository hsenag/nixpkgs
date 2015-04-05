{ stdenv, fetchurl, ghc, perl, gmp, ncurses, happy, alex }:

stdenv.mkDerivation rec {
  version = "7.10.1";
  name = "ghc-${version}";

  src = fetchurl {
    url = "https://www.haskell.org/ghc/dist/7.10.1/ghc-7.10.1-src.tar.bz2";
    sha256 = "0vzd64b53maff6jhg2n5vb1ycrzmygwv45dcfvxl06ks862ymqxz";
  };

  buildInputs = [ ghc perl ncurses happy alex ];

  preConfigure = ''
    echo >mk/build.mk "DYNAMIC_BY_DEFAULT = NO"
    sed -i -e 's|-isysroot /Developer/SDKs/MacOSX10.5.sdk||' configure
  '' + stdenv.lib.optionalString (!stdenv.isDarwin) ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -rpath $out/lib/ghc-${version}"
  '';

  configureFlags = [
    "--with-gcc=${stdenv.cc}/bin/cc"
    "--with-gmp-includes=${gmp}/include" "--with-gmp-libraries=${gmp}/lib"
  ];

  enableParallelBuilding = true;

  # required, because otherwise all symbols from HSffi.o are stripped, and
  # that in turn causes GHCi to abort
  stripDebugFlags = [ "-S" "--keep-file-symbols" ];

  meta = {
    homepage = "http://haskell.org/ghc";
    description = "The Glasgow Haskell Compiler";
    maintainers = with stdenv.lib.maintainers; [ marcweber andres simons ];
    inherit (ghc.meta) license platforms;
  };

}
