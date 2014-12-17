{ cabal, Cabal, filepath, HTTP, HUnit, mtl, network, networkUri
, QuickCheck, random, stm, testFramework, testFrameworkHunit
, testFrameworkQuickcheck2, time, zlib
}:

cabal.mkDerivation (self: {
  pname = "cabal-install";
  version = "1.20.0.4";
  sha256 = "171lkr8jw5k3l58gn41jmbp47kf3b8iq9dds0v8qx7wxzlxy0kz1";
  isLibrary = false;
  isExecutable = true;
  configureFlags = "-f-network-uri";
  buildDepends = [
    Cabal filepath HTTP mtl network networkUri random stm time zlib
  ];
  testDepends = [
    Cabal filepath HTTP HUnit mtl network QuickCheck stm testFramework
    testFrameworkHunit testFrameworkQuickcheck2 time zlib
  ];
  postInstall = ''
    mkdir $out/etc
    mv bash-completion $out/etc/bash_completion.d
  '';
  meta = {
    homepage = "http://www.haskell.org/cabal/";
    description = "The command-line interface for Cabal and Hackage";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
