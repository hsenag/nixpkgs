{ stdenv, fetchurl, ghc, pkgconfig, glibcLocales }:

{ pname, version, sha256
, buildDepends ? []
, extraLibraries ? []
, configureFlags ? []
, configureFlagsArray ? []
, pkgconfigDepends ? []
, noHaddock ? false
, buildTools ? []
, patches ? [], patchPhase ? "", prePatch ? "", postPatch ? ""
, configurePhase ? "", preConfigure ? "", postConfigure ? ""
, installPhase ? "", preInstall ? "", postInstall ? ""
, checkPhase ? "", preCheck ? "", postCheck ? ""
, isLibrary ? null, isExecutable ? null
, propagatedUserEnvPkgs ? []
, testDepends ? []
, doCheck ? true
, jailbreak ? false
, testTarget ? ""
, libPaths ? null
, meta
}:

assert pkgconfigDepends != [] -> pkgconfig != null;

stdenv.mkDerivation {
  name = "${pname}-${version}";

  src = fetchurl { url = "mirror://hackage/${pname}-${version}.tar.gz"; inherit sha256; };

  nativeBuildInputs = extraLibraries ++ buildTools ++
    stdenv.lib.optionals (pkgconfigDepends != []) ([pkgconfig] ++ pkgconfigDepends);
  propagatedNativeBuildInputs = buildDepends;

  inherit propagatedUserEnvPkgs;
  inherit preConfigure postConfigure configureFlags configureFlagsArray;
  inherit patches patchPhase prePatch postPatch;
  inherit preInstall postInstall;
  inherit preCheck postCheck;

  # GHC needs the locale configured during the Haddock phase.
  LANG = "en_US.UTF-8";
  LOCALE_ARCHIVE = stdenv.lib.optionalString stdenv.isLinux "${glibcLocales}/lib/locale/locale-archive";

  configurePhase = ''
    export PATH="${ghc}/bin:$PATH"
    runHook preConfigure
    configureFlags="-v --prefix=$out --ghc-option=-j$NIX_BUILD_CORES $configureFlags"
    for p in ${stdenv.lib.concatStringsSep " " (stdenv.lib.closePropagation buildDepends)}; do
      if [ -d "$p/lib/ghc-${ghc.version}/package.conf.d" ]; then
        for db in "$p/lib/ghc-${ghc.version}/package.conf.d/"*".db"; do
          configureFlags+=" --package-db=$db"
        done
        continue
      fi
    done
    for p in $nativeBuildInputs; do
      if [ -d "$p/include" ]; then
        configureFlags+=" --extra-include-dirs=$p/include"
      fi
      for d in lib{,64}; do
        if [ -d "$p/$d" ]; then
          configureFlags+=" --extra-lib-dirs=$p/$d"
        fi
      done
    done
    ghc --make Setup
    echo configureFlags: $configureFlags
    ./Setup configure $configureFlags
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    ./Setup build
    ${stdenv.lib.optionalString (!noHaddock) "./Setup haddock --html"}
    runHook postBuild
  '';

  checkPhase = if installPhase != "" then installPhase else ''
    runHook preCheck
    ./Setup check
    runHook postCheck
  '';

  installPhase = if installPhase != "" then installPhase else ''
    runHook preInstall
    ./Setup copy
    local confDir=$out/lib/ghc-${ghc.version}/package.conf.d
    local packageDb=$confDir/${pname}-${version}.db
    local pkgConf=$confDir/${pname}-${version}.conf
    mkdir -p $confDir
    ./Setup register --gen-pkg-config=$pkgConf
    if test -f $pkgConf; then
      echo '[]' > $packageDb
      GHC_PACKAGE_PATH=$packageDb ghc-pkg --global register $pkgConf --force
    fi
    runHook postInstall
  '';

  inherit meta;
}
