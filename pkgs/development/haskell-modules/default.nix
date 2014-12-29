{ pkgs, stdenv, ghc
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

      defaultScope = pkgs // pkgs.xlibs // pkgs.gnome // self;
      callPackage = pkg: args: stdenv.lib.callPackageWith defaultScope pkg args;

    in
      import ./hackage-packages.nix { inherit pkgs stdenv callPackage; } self // {

        inherit ghc mkDerivation;

        ghcWithPackages = pkgs: callPackage ./with-packages-wrapper.nix { packages = pkgs self; };

      };

  compatLayer = if provideOldAttributeNames then import ./compat-layer.nix else (self: super: {});
  commonConfiguration = import ./configuration-common.nix { inherit pkgs; };

in

  fix (extend (extend (extend (extend haskellPackages commonConfiguration) compatLayer) packageSetConfig) overrides)
