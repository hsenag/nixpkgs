{ pkgs }:

self: super: {

  # Disable GHC 7.6.x core libraries.
  array = null;
  base = null;
  binary = null;
  bin-package-db = null;
  bytestring = null;
  Cabal = null;
  containers = null;
  deepseq = null;
  directory = null;
  filepath = null;
  ghc-prim = null;
  haskell2010 = null;
  haskell98 = null;
  hoopl = null;
  hpc = null;
  integer-gmp = null;
  old-locale = null;
  old-time = null;
  pretty = null;
  process = null;
  rts = null;
  template-haskell = null;
  time = null;
  unix = null;

  # Needs latest Cabal.
  Cabal_1_20 = super.Cabal.overrideCabal (drv: { preCheck = "unset GHC_PACKAGE_PATH; export HOME=$NIX_BUILD_TOP"; doCheck = false;});
  cabal-install = (super.cabal-install.override { Cabal = self.Cabal_1_20; }).overrideCabal (drv: { doCheck = false; });
  jailbreak-cabal = super.jailbreak-cabal.override { Cabal = self.Cabal_1_20; };
}
