{ pkgs }:

self: super: {

  # Disable GHC 7.8.x core libraries.
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
  # haskeline = null;                                                   # Huh? Core package!
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
  terminfo = super.terminfo.override { inherit (pkgs) ncurses; };       # Huh? Core package!
  time = null;
  transformers = null;
  unix = null;
  xhtml = null;

  # We cannot use mtl 2.2.x with GHC versions < 7.9.x.
  mtl22 = super.mtl.override { transformers = super.transformers; };
  mtl = self.mtl21.override { transformers = null; };

  # transformers-compat doesn't auto-detect the correct flags for
  # building with transformers 0.3.x.
  transformers-compat = super.transformers-compat.overrideCabal (drv: { configureFlags = ["-fthree"] ++ drv.configureFlags or []; });

  # resourcet doesn't build otherwise.
  monad-control = super.monad-control-0_3_x;

  # Needs latest Cabal.
  Cabal_1_20 = super.Cabal.overrideCabal (drv: { preCheck = "unset GHC_PACKAGE_PATH; export HOME=$NIX_BUILD_TOP"; doCheck = false;});
  cabal-install = (super.cabal-install.override { Cabal = self.Cabal_1_20; }).overrideCabal (drv: { doCheck = false; });
  jailbreak-cabal = super.jailbreak-cabal.override { Cabal = self.Cabal_1_20; };
}
