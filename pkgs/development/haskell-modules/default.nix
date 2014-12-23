{ pkgs, newScope, stdenv, ghc
, packageSetConfig ? (self: super: {})
, overrides ? (self: super: {})
, provideOldAttributeNames ? false
}:

let

  fix = f: let x = f x // { __unfix__ = f; }; in x;

  extend = rattrs: f: self: let super = rattrs self; in super // f self super;

  haskellPackages = self:
    let

      mkHaskellDerivation = pkgs.callPackage ./generic-builder.nix {
        inherit stdenv ghc;
        inherit (pkgs) fetchurl pkgconfig glibcLocales coreutils gnugrep gnused;
        inherit (self) jailbreak-cabal;
        hscolour = self.hscolour.overrideCabal (drv: {
          isLibrary = false;
          noHaddock = true;
          hyperlinkSource = false;      # Avoid depending on hscolour for this build.
          postFixup = "rm -rf $out/lib $out/share $out/nix-support";
        });
      };

      mkDerivation = args: stdenv.lib.addPassthru (mkHaskellDerivation args) {
        overrideCabal = f: callPackage mkDerivation (args // (f args));
      };

      callPackage = pkg: args: newScope self pkg args;

    in
      import ./hackage-packages.nix { inherit pkgs stdenv callPackage; } self // {

        inherit ghc mkDerivation;

        mtl21 = callPackage
                ({ mkDerivation, transformers }:
                 mkDerivation {
                   pname = "mtl";
                   version = "2.1.3.1";
                   sha256 = "1xpn2wjmqbh2cg1yssc6749xpgcqlrrg4iilwqgkcjgvaxlpdbvp";
                   buildDepends = [ transformers ];
                   homepage = "http://github.com/ekmett/mtl";
                   description = "Monad classes, using functional dependencies";
                   license = stdenv.lib.licenses.bsd3;
                  }) {};

        monad-control-0_3_x = callPackage
                ({ mkDerivation, transformers, transformers-base }:
                mkDerivation {
                  pname = "monad-control";
                  version = "0.3.3.0";
                  sha256 = "0vjff64iwnd9vplqfjyylbd900qmsr92h62hnh715wk06yacji7g";
                  buildDepends = [ transformers transformers-base ];
                  homepage = "https://github.com/basvandijk/monad-control";
                  description = "Lift control operations, like exception catching, through monad transformers";
                  license = stdenv.lib.licenses.bsd3;
                }) {};

         ghcWithPackages = packages: pkgs.callPackage ../compilers/ghc/with-packages.nix {
           inherit stdenv ghc packages;
         };

      };

  compatLayer = if provideOldAttributeNames then import ./compat-layer.nix else (self: super: {});
  commonConfiguration = import ./configuration-common.nix { inherit pkgs; };

in

  fix (extend (extend (extend (extend haskellPackages commonConfiguration) compatLayer) packageSetConfig) overrides)
