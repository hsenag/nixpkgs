{ stdenv, fetchurl, ghc, pkgconfig, glibcLocales, coreutils, gnugrep }:

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
, isExecutable ? false, isLibrary ? !isExecutable
, propagatedUserEnvPkgs ? []
, testDepends ? []
, doCheck ? stdenv.lib.versionOlder "7.4" ghc.version, testTarget ? ""
, jailbreak ? false
, meta
, enableHyperlinkSource ? true
, enableLibraryProfiling ? false
, enableSharedExecutables ? stdenv.lib.versionOlder "7.7" ghc.version
, enableSharedLibraries ? stdenv.lib.versionOlder "7.7" ghc.version
, enableSplitObjs ? !stdenv.isDarwin # http://hackage.haskell.org/trac/ghc/ticket/4013
, enableStaticLibraries ? true
}:

assert pkgconfigDepends != [] -> pkgconfig != null;

let

  inherit (stdenv.lib) optional optionals optionalString versionOlder
                       concatStringsSep closePropagation enableFeature;

  defaultSetupHs = builtins.toFile "Setup.hs" ''
                     import Distribution.Simple
                     main = defaultMain
                   '';

  defaultConfigureFlags = [
    (enableFeature enableSplitObjs "split-objs")
    (enableFeature enableLibraryProfiling "library-profiling")
    (enableFeature enableSharedLibraries "shared")
    (optionalString (versionOlder "7" ghc.version) (enableFeature enableStaticLibraries "library-vanilla"))
    (optionalString (versionOlder "7.4" ghc.version) (enableFeature enableSharedExecutables "executable-dynamic"))
    (optionalString (versionOlder "7" ghc.version) (enableFeature doCheck "tests"))
  ];

in
stdenv.mkDerivation {
  name = "${pname}-${version}";

  src = fetchurl { url = "mirror://hackage/${pname}-${version}.tar.gz"; inherit sha256; };

  nativeBuildInputs = extraLibraries ++ buildTools ++
    optionals (pkgconfigDepends != []) ([pkgconfig] ++ pkgconfigDepends) ++
    optionals doCheck testDepends;
  propagatedNativeBuildInputs = buildDepends;

  inherit propagatedUserEnvPkgs;
  inherit preConfigure postConfigure configureFlags configureFlagsArray;
  inherit patches patchPhase prePatch postPatch;
  inherit preInstall postInstall;
  inherit /*doCheck*/ preCheck postCheck;

  # GHC needs the locale configured during the Haddock phase.
  LANG = "en_US.UTF-8";
  LOCALE_ARCHIVE = optionalString stdenv.isLinux "${glibcLocales}/lib/locale/locale-archive";

  configurePhase = ''
    export PATH="${ghc}/bin:$PATH"
    runHook preConfigure

    configureFlags="--verbose --prefix=$out --libdir=\$prefix/lib/\$compiler --libsubdir=\$pkgid $configureFlags"
    configureFlags+=' ${concatStringsSep " " defaultConfigureFlags}'
    ${optionalString (enableSharedExecutables && stdenv.isLinux) ''
      configureFlags+=" --ghc-option=-optl=-Wl,-rpath=$out/lib/${ghc.name}/${pname}-${version}"
    ''}
    ${optionalString (enableSharedExecutables && stdenv.isDarwin) ''
      configureFlags+=" --ghc-option=-optl=-Wl,-headerpad_max_install_names"
    ''}
    ${optionalString (versionOlder "7.8" ghc.version && !isLibrary) ''
      configureFlags+=" --ghc-option=-j$NIX_BUILD_CORES"
    ''}

    for p in ${concatStringsSep " " (closePropagation buildDepends)} $nativeBuildInputs; do
      if [ -d "$p/lib/ghc-${ghc.version}/package.conf.d" ]; then
        for db in "$p/lib/ghc-${ghc.version}/package.conf.d/"*".db"; do
          configureFlags+=" --package-db=$db"
        done
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

    for i in Setup.hs Setup.lhs ${defaultSetupHs}; do
      test -f $i && break
    done
    ghc --make -o Setup -odir $TMPDIR -hidir $TMPDIR $i

    echo configureFlags: $configureFlags
    ./Setup configure $configureFlags 2>&1 | ${coreutils}/bin/tee "$NIX_BUILD_TOP/cabal-configure.log"
    if ${gnugrep}/bin/egrep -q '^Warning:.*depends on multiple versions' "$NIX_BUILD_TOP/cabal-configure.log"; then
      echo >&2 "*** abort because of serious configure-time warning from Cabal"
      exit 1
    fi

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    ./Setup build
    ${optionalString (!noHaddock) "./Setup haddock --html"}
    runHook postBuild
  '';

  doCheck = false;

  checkPhase = if installPhase != "" then installPhase else ''
    runHook preCheck
    ./Setup test ${testTarget}
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
