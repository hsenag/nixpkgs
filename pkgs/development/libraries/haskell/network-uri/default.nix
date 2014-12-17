{ cabal }:

cabal.mkDerivation (self: {
  pname = "network-uri";
  version = "2.5.0.0";
  sha256 = "0ki2iyvgvwwdj42z3biqz4680axn62qjv8ahx05i7n23g78cbv63";
  noHaddock = true;
  meta = {
    homepage = "https://github.com/haskell/network-uri";
    description = "URI manipulation";
    license = self.stdenv.lib.licenses.bsd3;
    platforms = self.ghc.meta.platforms;
  };
})
