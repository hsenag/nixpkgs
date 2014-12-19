{ pkgs, newScope, stdenv, fetchurl, ghc
, overrides ? (self: super: {})
, provideOldAttributeNames ? false
}:

let

  fix = f: let x = f x // { __unfix__ = f; }; in x;

  extend = rattrs: f: self: let super = rattrs self; in super // f self super;

  haskellPackages = self:
    let

      mkHaskellDerivation = pkgs.callPackage ./generic-builder.nix {
        inherit stdenv ghc fetchurl;
        inherit (pkgs) pkgconfig glibcLocales coreutils gnugrep gnused;
        inherit (self) jailbreak-cabal;
      };

      mkDerivation = args: stdenv.lib.addPassthru (mkHaskellDerivation args) {
        overrideCabal = f: mkDerivation (args // (f args));
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

  defaultConfiguration = self: super: {
    # Disable GHC 7.8.3 core libraries.
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
    # haskeline = null;                                                 # Huh? Core package!
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
    terminfo = super.terminfo.override { inherit (pkgs) ncurses; };     # Huh? Core package!
    time = null;
    transformers = null;
    unix = null;
    xhtml = null;

    # Break infinite recursions.
    digest = super.digest.override { inherit (pkgs) zlib; };
    matlab = super.matlab.override { matlab = null; };

    # We cannot use mtl 2.2.x with GHC versions < 7.9.x.
    mtl22 = super.mtl.override { transformers = super.transformers; };
    mtl = self.mtl21.override { transformers = null; };

    # transformers-compat doesn't auto-detect the correct flags for
    # building with transformers 0.3.x.
    transformers-compat = super.transformers-compat.overrideCabal (drv: { configureFlags = ["-fthree"] ++ drv.configureFlags or []; });

    # Doesn't compile with lua 5.2.
    hslua = super.hslua.override { lua = pkgs.lua5_1; };

    # resourcet doesn't build otherwise.
    monad-control = super.monad-control-0_3_x;

    # Needs latest Cabal.
    Cabal_1_20 = super.Cabal.overrideCabal (drv: { preCheck = "unset GHC_PACKAGE_PATH; export HOME=$NIX_BUILD_TOP"; doCheck = false;});
    cabal-install = (super.cabal-install.override { Cabal = self.Cabal_1_20; }).overrideCabal (drv: { doCheck = false; });
    jailbreak-cabal = super.jailbreak-cabal.override { Cabal = self.Cabal_1_20; };

    # Depends on code distributed under a non-free license.
    yices-painless = super.yices-painless.overrideCabal (drv: { hydraPlatforms = []; });

    abstract-deque = super.abstract-deque.overrideCabal (drv: { doCheck = false; });
    accelerate-cuda = super.accelerate-cuda.overrideCabal (drv: { jailbreak = true; });
    accelerate = super.accelerate.overrideCabal (drv: { jailbreak = true; });
    active = super.active.overrideCabal (drv: { jailbreak = true; });
    aeson-utils = super.aeson-utils.overrideCabal (drv: { jailbreak = true; });
    Agda = super.Agda.overrideCabal (drv: { jailbreak = true; noHaddock = true; });
    amqp = super.amqp.overrideCabal (drv: { doCheck = false; });
    arbtt = super.arbtt.overrideCabal (drv: { jailbreak = true; });
    ariadne = super.ariadne.overrideCabal (drv: { doCheck = false; });
    arithmoi = super.arithmoi.overrideCabal (drv: { jailbreak = true; });
    asn1-encoding = super.asn1-encoding.overrideCabal (drv: { doCheck = false; });
    assert-failure = super.assert-failure.overrideCabal (drv: { jailbreak = true; });
    atto-lisp = super.atto-lisp.overrideCabal (drv: { jailbreak = true; });
    attoparsec-conduit = super.attoparsec-conduit.overrideCabal (drv: { noHaddock = true; });
    authenticate-oauth = super.authenticate-oauth.overrideCabal (drv: { jailbreak = true; });
    aws = super.aws.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    base64-bytestring = super.base64-bytestring.overrideCabal (drv: { doCheck = false; });
    benchpress = super.benchpress.overrideCabal (drv: { jailbreak = true; });
    binary-conduit = super.binary-conduit.overrideCabal (drv: { jailbreak = true; });
    bindings-GLFW = super.bindings-GLFW.overrideCabal (drv: { doCheck = false; });
    bitset = super.bitset.overrideCabal (drv: { doCheck = false; });
    blaze-builder-conduit = super.blaze-builder-conduit.overrideCabal (drv: { noHaddock = true; });
    blaze-builder-enumerator = super.blaze-builder-enumerator.overrideCabal (drv: { jailbreak = true; });
    blaze-svg = super.blaze-svg.overrideCabal (drv: { jailbreak = true; });
    boundingboxes = super.boundingboxes.overrideCabal (drv: { doCheck = false; });
    bson = super.bson.overrideCabal (drv: { doCheck = false; });
    bytestring-progress = super.bytestring-progress.overrideCabal (drv: { noHaddock = true; });
    cabal2ghci = super.cabal2ghci.overrideCabal (drv: { jailbreak = true; });
    cabal-bounds = super.cabal-bounds.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    cabal-cargs = super.cabal-cargs.overrideCabal (drv: { jailbreak = true; });
    cabal-lenses = super.cabal-lenses.overrideCabal (drv: { jailbreak = true; });
    cabal-macosx = super.cabal-macosx.overrideCabal (drv: { jailbreak = true; });
    cabal-meta = super.cabal-meta.overrideCabal (drv: { doCheck = false; });
    cairo = super.cairo.overrideCabal (drv: { jailbreak = true; });
    cautious-file = super.cautious-file.overrideCabal (drv: { doCheck = false; });
    certificate = super.certificate.overrideCabal (drv: { jailbreak = true; });
    Chart-cairo = super.Chart-cairo.overrideCabal (drv: { jailbreak = true; });
    Chart-diagrams = super.Chart-diagrams.overrideCabal (drv: { jailbreak = true; });
    Chart = super.Chart.overrideCabal (drv: { jailbreak = true; });
    ChasingBottoms = super.ChasingBottoms.overrideCabal (drv: { jailbreak = true; });
    cheapskate = super.cheapskate.overrideCabal (drv: { jailbreak = true; });
    citeproc-hs = super.citeproc-hs.overrideCabal (drv: { jailbreak = true; });
    clay = super.clay.overrideCabal (drv: { jailbreak = true; });
    cmdtheline = super.cmdtheline.overrideCabal (drv: { doCheck = false; });
    codex = super.codex.overrideCabal (drv: { jailbreak = true; });
    command-qq = super.command-qq.overrideCabal (drv: { doCheck = false; });
    comonads-fd = super.comonads-fd.overrideCabal (drv: { noHaddock = true; });
    comonad-transformers = super.comonad-transformers.overrideCabal (drv: { noHaddock = true; });
    concrete-typerep = super.concrete-typerep.overrideCabal (drv: { doCheck = false; });
    conduit-extra = super.conduit-extra.overrideCabal (drv: { doCheck = false; });
    conduit = super.conduit.overrideCabal (drv: { doCheck = false; });
    CouchDB = super.CouchDB.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    criterion = super.criterion.overrideCabal (drv: { doCheck = false; });
    crypto-conduit = super.crypto-conduit.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    crypto-numbers = super.crypto-numbers.overrideCabal (drv: { doCheck = false; });
    cuda = super.cuda.overrideCabal (drv: { doCheck = false; });
    data-accessor = super.data-accessor.overrideCabal (drv: { jailbreak = true; });
    dataenc = super.dataenc.overrideCabal (drv: { jailbreak = true; });
    data-fin = super.data-fin.overrideCabal (drv: { jailbreak = true; });
    data-lens = super.data-lens.overrideCabal (drv: { jailbreak = true; });
    data-pprint = super.data-pprint.overrideCabal (drv: { jailbreak = true; });
    dbmigrations = super.dbmigrations.overrideCabal (drv: { jailbreak = true; });
    dbus = super.dbus.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    deepseq-th = super.deepseq-th.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    diagrams-contrib = super.diagrams-contrib.overrideCabal (drv: { jailbreak = true; });
    diagrams-core = super.diagrams-core.overrideCabal (drv: { jailbreak = true; });
    diagrams-lib = super.diagrams-lib.overrideCabal (drv: { jailbreak = true; });
    diagrams-postscript = super.diagrams-postscript.overrideCabal (drv: { jailbreak = true; });
    diagrams-rasterific = super.diagrams-rasterific.overrideCabal (drv: { jailbreak = true; });
    diagrams = super.diagrams.overrideCabal (drv: { noHaddock = true; jailbreak = true; });
    diagrams-svg = super.diagrams-svg.overrideCabal (drv: { jailbreak = true; });
    digestive-functors-heist = super.digestive-functors-heist.overrideCabal (drv: { jailbreak = true; });
    digestive-functors-snap = super.digestive-functors-snap.overrideCabal (drv: { jailbreak = true; });
    digestive-functors = super.digestive-functors.overrideCabal (drv: { jailbreak = true; });
    directory-layout = super.directory-layout.overrideCabal (drv: { doCheck = false; });
    distributed-process-platform = super.distributed-process-platform.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    distributed-process = super.distributed-process.overrideCabal (drv: { jailbreak = true; });
    doctest = super.doctest.overrideCabal (drv: { noHaddock = true; doCheck = false; });
    dom-selector = super.dom-selector.overrideCabal (drv: { doCheck = false; });
    download-curl = super.download-curl.overrideCabal (drv: { jailbreak = true; });
    dual-tree = super.dual-tree.overrideCabal (drv: { jailbreak = true; });
    Dust-crypto = super.Dust-crypto.overrideCabal (drv: { doCheck = false; });
    either = super.either.overrideCabal (drv: { noHaddock = true; });
    ekg = super.ekg.overrideCabal (drv: { jailbreak = true; });
    elm-get = super.elm-get.overrideCabal (drv: { jailbreak = true; });
    elm-server = super.elm-server.overrideCabal (drv: { jailbreak = true; });
    encoding = super.encoding.overrideCabal (drv: { jailbreak = true; });
    enummapset = super.enummapset.overrideCabal (drv: { jailbreak = true; });
    equational-reasoning = super.equational-reasoning.overrideCabal (drv: { jailbreak = true; });
    equivalence = super.equivalence.overrideCabal (drv: { doCheck = false; });
    errors = super.errors.overrideCabal (drv: { jailbreak = true; });
    extensible-effects = super.extensible-effects.overrideCabal (drv: { jailbreak = true; });
    failure = super.failure.overrideCabal (drv: { jailbreak = true; });
    fay = super.fay.overrideCabal (drv: { jailbreak = true; });
    fb = super.fb.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    filestore = super.filestore.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    force-layout = super.force-layout.overrideCabal (drv: { jailbreak = true; });
    free-game = super.free-game.overrideCabal (drv: { jailbreak = true; });
    free = super.free.overrideCabal (drv: { jailbreak = true; });
    fsnotify = super.fsnotify.overrideCabal (drv: { doCheck = false; });
    ghc-events = super.ghc-events.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    ghcid = super.ghcid.overrideCabal (drv: { doCheck = false; });
    ghc-mod = super.ghc-mod.overrideCabal (drv: { doCheck = false; });
    gitit = super.gitit.overrideCabal (drv: { jailbreak = true; });
    glade = super.glade.overrideCabal (drv: { jailbreak = true; });
    GLFW-b = super.GLFW-b.overrideCabal (drv: { doCheck = false; });
    gloss-raster = super.gloss-raster.overrideCabal (drv: { jailbreak = true; });
    gl = super.gl.overrideCabal (drv: { noHaddock = true; });
    gnuplot = super.gnuplot.overrideCabal (drv: { jailbreak = true; });
    Graphalyze = super.Graphalyze.overrideCabal (drv: { jailbreak = true; });
    graphviz = super.graphviz.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    grid = super.grid.overrideCabal (drv: { doCheck = false; });
    groupoids = super.groupoids.overrideCabal (drv: { noHaddock = true; });
    gtk-traymanager = super.gtk-traymanager.overrideCabal (drv: { jailbreak = true; });
    hakyll = super.hakyll.overrideCabal (drv: { jailbreak = true; });
    hamlet = super.hamlet.overrideCabal (drv: { noHaddock = true; });
    handa-gdata = super.handa-gdata.overrideCabal (drv: { doCheck = false; });
    HandsomeSoup = super.HandsomeSoup.overrideCabal (drv: { jailbreak = true; });
    happstack-server = super.happstack-server.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    hashable = super.hashable.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    hashed-storage = super.hashed-storage.overrideCabal (drv: { doCheck = false; });
    haskeline = super.haskeline.overrideCabal (drv: { jailbreak = true; });
    haskell-docs = super.haskell-docs.overrideCabal (drv: { doCheck = false; });
    haskell-names = super.haskell-names.overrideCabal (drv: { doCheck = false; });
    haskell-src-exts = super.haskell-src-exts.overrideCabal (drv: { doCheck = false; });
    haskell-src-meta = super.haskell-src-meta.overrideCabal (drv: { jailbreak = true; });
    haskoin = super.haskoin.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    hasktags = super.hasktags.overrideCabal (drv: { jailbreak = true; });
    hasql-postgres = super.hasql-postgres.overrideCabal (drv: { doCheck = false; });
    haste-compiler = super.haste-compiler.overrideCabal (drv: { noHaddock = true; });
    haxl = super.haxl.overrideCabal (drv: { jailbreak = true; });
    HaXml = super.HaXml.overrideCabal (drv: { noHaddock = true; });
    haxr = super.haxr.overrideCabal (drv: { jailbreak = true; });
    hcltest = super.hcltest.overrideCabal (drv: { jailbreak = true; });
    HDBC-odbc = super.HDBC-odbc.overrideCabal (drv: { noHaddock = true; });
    hedis = super.hedis.overrideCabal (drv: { doCheck = false; });
    heist = super.heist.overrideCabal (drv: { jailbreak = true; });
    hindent = super.hindent.overrideCabal (drv: { doCheck = false; });
    hi = super.hi.overrideCabal (drv: { doCheck = false; });
    hjsmin = super.hjsmin.overrideCabal (drv: { jailbreak = true; });
    hledger-web = super.hledger-web.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    HList = super.HList.overrideCabal (drv: { doCheck = false; });
    hoauth2 = super.hoauth2.overrideCabal (drv: { jailbreak = true; });
    holy-project = super.holy-project.overrideCabal (drv: { doCheck = false; });
    hoodle-core = super.hoodle-core.overrideCabal (drv: { noHaddock = true; });
    hsbencher-fusion = super.hsbencher-fusion.overrideCabal (drv: { doCheck = false; });
    hsbencher = super.hsbencher.overrideCabal (drv: { doCheck = false; });
    hsc3-db = super.hsc3-db.overrideCabal (drv: { noHaddock = true; });
    hsimport = super.hsimport.overrideCabal (drv: { jailbreak = true; });
    hsini = super.hsini.overrideCabal (drv: { jailbreak = true; });
    hspec-discover = super.hspec-discover.overrideCabal (drv: { noHaddock = true; });
    hspec-expectations = super.hspec-expectations.overrideCabal (drv: { doCheck = false; });
    hspec-meta = super.hspec-meta.overrideCabal (drv: { doCheck = false; });
    hspec = super.hspec.overrideCabal (drv: { doCheck = false; });
    hsyslog = super.hsyslog.overrideCabal (drv: { noHaddock = true; });
    HTF = super.HTF.overrideCabal (drv: { doCheck = false; });
    http-attoparsec = super.http-attoparsec.overrideCabal (drv: { jailbreak = true; });
    http-client-conduit = super.http-client-conduit.overrideCabal (drv: { noHaddock = true; });
    http-client-multipart = super.http-client-multipart.overrideCabal (drv: { noHaddock = true; });
    http-client = super.http-client.overrideCabal (drv: { doCheck = false; });
    http-client-tls = super.http-client-tls.overrideCabal (drv: { doCheck = false; });
    http-conduit = super.http-conduit.overrideCabal (drv: { doCheck = false; });
    httpd-shed = super.httpd-shed.overrideCabal (drv: { jailbreak = true; });
    http-reverse-proxy = super.http-reverse-proxy.overrideCabal (drv: { doCheck = false; });
    http-streams = super.http-streams.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    HTTP = super.HTTP.overrideCabal (drv: { doCheck = false; noHaddock = true; });
    http-types = super.http-types.overrideCabal (drv: { jailbreak = true; });
    idris = super.idris.overrideCabal (drv: { jailbreak = true; });
    ihaskell = super.ihaskell.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    js-jquery = super.js-jquery.overrideCabal (drv: { doCheck = false; });
    json-assertions = super.json-assertions.overrideCabal (drv: { jailbreak = true; });
    json-rpc = super.json-rpc.overrideCabal (drv: { jailbreak = true; });
    json-schema = super.json-schema.overrideCabal (drv: { jailbreak = true; });
    kansas-lava = super.kansas-lava.overrideCabal (drv: { jailbreak = true; });
    keys = super.keys.overrideCabal (drv: { jailbreak = true; });
    language-c-quote = super.language-c-quote.overrideCabal (drv: { jailbreak = true; });
    language-ecmascript = super.language-ecmascript.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    language-java = super.language-java.overrideCabal (drv: { doCheck = false; });
    largeword = super.largeword.overrideCabal (drv: { jailbreak = true; });
    libjenkins = super.libjenkins.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    libsystemd-journal = super.libsystemd-journal.overrideCabal (drv: { jailbreak = true; });
    lifted-base = super.lifted-base.overrideCabal (drv: { doCheck = false; });
    linear = super.linear.overrideCabal (drv: { doCheck = false; });
    ListLike = super.ListLike.overrideCabal (drv: { jailbreak = true; });
    list-tries = super.list-tries.overrideCabal (drv: { jailbreak = true; });
    llvm-general-pure = super.llvm-general-pure.overrideCabal (drv: { doCheck = false; });
    llvm-general = super.llvm-general.overrideCabal (drv: { doCheck = false; });
    lzma-enumerator = super.lzma-enumerator.overrideCabal (drv: { jailbreak = true; });
    machines-directory = super.machines-directory.overrideCabal (drv: { jailbreak = true; });
    machines-io = super.machines-io.overrideCabal (drv: { jailbreak = true; });
    mainland-pretty = super.mainland-pretty.overrideCabal (drv: { jailbreak = true; });
    markdown-unlit = super.markdown-unlit.overrideCabal (drv: { noHaddock = true; });
    math-functions = super.math-functions.overrideCabal (drv: { doCheck = false; });
    MissingH = super.MissingH.overrideCabal (drv: { doCheck = false; });
    MonadCatchIO-mtl = super.MonadCatchIO-mtl.overrideCabal (drv: { jailbreak = true; });
    MonadCatchIO-transformers = super.MonadCatchIO-transformers.overrideCabal (drv: { jailbreak = true; });
    monadloc-pp = super.monadloc-pp.overrideCabal (drv: { jailbreak = true; });
    monad-par = super.monad-par.overrideCabal (drv: { doCheck = false; });
    monoid-extras = super.monoid-extras.overrideCabal (drv: { jailbreak = true; });
    mpppc = super.mpppc.overrideCabal (drv: { jailbreak = true; });
    msgpack = super.msgpack.overrideCabal (drv: { jailbreak = true; });
    multiplate = super.multiplate.overrideCabal (drv: { jailbreak = true; });
    mwc-random = super.mwc-random.overrideCabal (drv: { doCheck = false; });
    nanospec = super.nanospec.overrideCabal (drv: { doCheck = false; });
    network-carbon = super.network-carbon.overrideCabal (drv: { jailbreak = true; });
    network-conduit = super.network-conduit.overrideCabal (drv: { noHaddock = true; });
    network-simple = super.network-simple.overrideCabal (drv: { jailbreak = true; });
    network-transport-tcp = super.network-transport-tcp.overrideCabal (drv: { doCheck = false; });
    network-transport-tests = super.network-transport-tests.overrideCabal (drv: { jailbreak = true; });
    network-uri = super.network-uri.overrideCabal (drv: { doCheck = false; });
    numeric-prelude = super.numeric-prelude.overrideCabal (drv: { jailbreak = true; });
    ofx = super.ofx.overrideCabal (drv: { jailbreak = true; });
    opaleye = super.opaleye.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    openssl-streams = super.openssl-streams.overrideCabal (drv: { jailbreak = true; });
    options = super.options.overrideCabal (drv: { doCheck = false; });
    optparse-applicative = super.optparse-applicative.overrideCabal (drv: { jailbreak = true; });
    packunused = super.packunused.overrideCabal (drv: { jailbreak = true; });
    pandoc-citeproc = super.pandoc-citeproc.overrideCabal (drv: { doCheck = false; });
    pandoc = super.pandoc.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    parallel-io = super.parallel-io.overrideCabal (drv: { jailbreak = true; });
    parsec = super.parsec.overrideCabal (drv: { jailbreak = true; });
    permutation = super.permutation.overrideCabal (drv: { doCheck = false; });
    persistent-postgresql = super.persistent-postgresql.overrideCabal (drv: { jailbreak = true; });
    persistent-template = super.persistent-template.overrideCabal (drv: { jailbreak = true; });
    pipes-aeson = super.pipes-aeson.overrideCabal (drv: { jailbreak = true; doCheck = false; });
    pipes-binary = super.pipes-binary.overrideCabal (drv: { jailbreak = true; });
    pipes-http = super.pipes-http.overrideCabal (drv: { jailbreak = true; });
    pipes-network = super.pipes-network.overrideCabal (drv: { jailbreak = true; });
    pipes-shell = super.pipes-shell.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    pipes = super.pipes.overrideCabal (drv: { jailbreak = true; });
    pipes-text = super.pipes-text.overrideCabal (drv: { jailbreak = true; });
    pointed = super.pointed.overrideCabal (drv: { jailbreak = true; });
    pointfree = super.pointfree.overrideCabal (drv: { jailbreak = true; });
    postgresql-simple = super.postgresql-simple.overrideCabal (drv: { doCheck = false; });
    process-conduit = super.process-conduit.overrideCabal (drv: { doCheck = false; });
    product-profunctors = super.product-profunctors.overrideCabal (drv: { jailbreak = true; });
    prolog = super.prolog.overrideCabal (drv: { jailbreak = true; });
    punycode = super.punycode.overrideCabal (drv: { doCheck = false; });
    quickcheck-instances = super.quickcheck-instances.overrideCabal (drv: { jailbreak = true; });
    QuickCheck = super.QuickCheck.overrideCabal (drv: { noHaddock = true; });
    Rasterific = super.Rasterific.overrideCabal (drv: { doCheck = false; });
    reactive-banana-wx = super.reactive-banana-wx.overrideCabal (drv: { jailbreak = true; });
    ReadArgs = super.ReadArgs.overrideCabal (drv: { jailbreak = true; });
    reducers = super.reducers.overrideCabal (drv: { jailbreak = true; });
    rematch = super.rematch.overrideCabal (drv: { doCheck = false; });
    repa-algorithms = super.repa-algorithms.overrideCabal (drv: { jailbreak = true; });
    repa-examples = super.repa-examples.overrideCabal (drv: { jailbreak = true; });
    repa-io = super.repa-io.overrideCabal (drv: { jailbreak = true; });
    RepLib = super.RepLib.overrideCabal (drv: { noHaddock = true; });
    rest-core = super.rest-core.overrideCabal (drv: { jailbreak = true; });
    rest-gen = super.rest-gen.overrideCabal (drv: { jailbreak = true; });
    rest-stringmap = super.rest-stringmap.overrideCabal (drv: { jailbreak = true; });
    rest-types = super.rest-types.overrideCabal (drv: { jailbreak = true; });
    rethinkdb = super.rethinkdb.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    retry = super.retry.overrideCabal (drv: { jailbreak = true; });
    rope = super.rope.overrideCabal (drv: { jailbreak = true; });
    RSA = super.RSA.overrideCabal (drv: { doCheck = false; });
    scientific = super.scientific.overrideCabal (drv: { jailbreak = true; });
    scotty = super.scotty.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    sdl2 = super.sdl2.overrideCabal (drv: { noHaddock = true; });
    serialport = super.serialport.overrideCabal (drv: { doCheck = false; });
    setenv = super.setenv.overrideCabal (drv: { doCheck = false; });
    setlocale = super.setlocale.overrideCabal (drv: { jailbreak = true; });
    shakespeare-css = super.shakespeare-css.overrideCabal (drv: { noHaddock = true; });
    shakespeare-i18n = super.shakespeare-i18n.overrideCabal (drv: { noHaddock = true; });
    shakespeare-js = super.shakespeare-js.overrideCabal (drv: { noHaddock = true; });
    shakespeare-text = super.shakespeare-text.overrideCabal (drv: { noHaddock = true; });
    simple-sendfile = super.simple-sendfile.overrideCabal (drv: { doCheck = false; });
    singletons = super.singletons.overrideCabal (drv: { noHaddock = true; });
    skein = super.skein.overrideCabal (drv: { jailbreak = true; });
    snap-core = super.snap-core.overrideCabal (drv: { jailbreak = true; });
    snaplet-acid-state = super.snaplet-acid-state.overrideCabal (drv: { jailbreak = true; });
    snaplet-redis = super.snaplet-redis.overrideCabal (drv: { jailbreak = true; });
    snaplet-stripe = super.snaplet-stripe.overrideCabal (drv: { jailbreak = true; });
    snap-web-routes = super.snap-web-routes.overrideCabal (drv: { jailbreak = true; });
    snowball = super.snowball.overrideCabal (drv: { doCheck = false; });
    sparse = super.sparse.overrideCabal (drv: { doCheck = false; });
    statistics = super.statistics.overrideCabal (drv: { doCheck = false; });
    stm-containers = super.stm-containers.overrideCabal (drv: { doCheck = false; });
    storable-record = super.storable-record.overrideCabal (drv: { jailbreak = true; });
    Strafunski-StrategyLib = super.Strafunski-StrategyLib.overrideCabal (drv: { jailbreak = true; });
    stripe = super.stripe.overrideCabal (drv: { jailbreak = true; });
    symbol = super.symbol.overrideCabal (drv: { jailbreak = true; });
    system-filepath = super.system-filepath.overrideCabal (drv: { doCheck = false; });
    tabular = super.tabular.overrideCabal (drv: { jailbreak = true; });
    tar = super.tar.overrideCabal (drv: { noHaddock = true; });
    template-default = super.template-default.overrideCabal (drv: { jailbreak = true; });
    temporary = super.temporary.overrideCabal (drv: { jailbreak = true; });
    test-framework-quickcheck2 = super.test-framework-quickcheck2.overrideCabal (drv: { jailbreak = true; });
    text = super.text.overrideCabal (drv: { doCheck = false; });
    th-desugar = super.th-desugar.overrideCabal (drv: { doCheck = false; });
    these = super.these.overrideCabal (drv: { jailbreak = true; });
    th-lift-instances = super.th-lift-instances.overrideCabal (drv: { jailbreak = true; });
    th-orphans = super.th-orphans.overrideCabal (drv: { jailbreak = true; });
    thread-local-storage = super.thread-local-storage.overrideCabal (drv: { doCheck = false; });
    threads = super.threads.overrideCabal (drv: { doCheck = false; });
    threepenny-gui = super.threepenny-gui.overrideCabal (drv: { jailbreak = true; });
    thyme = super.thyme.overrideCabal (drv: { doCheck = false; });
    timeparsers = super.timeparsers.overrideCabal (drv: { jailbreak = true; });
    tls = super.tls.overrideCabal (drv: { doCheck = false; });
    twitter-types = super.twitter-types.overrideCabal (drv: { doCheck = false; });
    unordered-containers = super.unordered-containers.overrideCabal (drv: { doCheck = false; });
    uri-encode = super.uri-encode.overrideCabal (drv: { jailbreak = true; });
    usb = super.usb.overrideCabal (drv: { jailbreak = true; });
    utf8-string = super.utf8-string.overrideCabal (drv: { noHaddock = true; });
    uuid = super.uuid.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    vacuum-graphviz = super.vacuum-graphviz.overrideCabal (drv: { jailbreak = true; });
    vault = super.vault.overrideCabal (drv: { jailbreak = true; });
    vcswrapper = super.vcswrapper.overrideCabal (drv: { jailbreak = true; });
    vty = super.vty.overrideCabal (drv: { doCheck = false; });
    vty-ui = super.vty-ui.overrideCabal (drv: { jailbreak = true; });
    wai-extra = super.wai-extra.overrideCabal (drv: { jailbreak = true; });
    wai-logger = super.wai-logger.overrideCabal (drv: { doCheck = false; });
    wai-middleware-static = super.wai-middleware-static.overrideCabal (drv: { jailbreak = true; });
    wai-test = super.wai-test.overrideCabal (drv: { noHaddock = true; });
    wai-websockets = super.wai-websockets.overrideCabal (drv: { jailbreak = true; });
    warp = super.warp.overrideCabal (drv: { doCheck = false; });
    webdriver = super.webdriver.overrideCabal (drv: { doCheck = false; jailbreak = true; });
    websockets-snap = super.websockets-snap.overrideCabal (drv: { jailbreak = true; });
    websockets = super.websockets.overrideCabal (drv: { jailbreak = true; });
    wl-pprint-terminfo = super.wl-pprint-terminfo.overrideCabal (drv: { jailbreak = true; });
    wl-pprint-text = super.wl-pprint-text.overrideCabal (drv: { jailbreak = true; });
    wreq = super.wreq.overrideCabal (drv: { doCheck = false; });
    wxc = super.wxc.overrideCabal (drv: { noHaddock = true; });
    wxdirect = super.wxdirect.overrideCabal (drv: { jailbreak = true; });
    xdot = super.xdot.overrideCabal (drv: { jailbreak = true; });
    xml-conduit = super.xml-conduit.overrideCabal (drv: { jailbreak = true; });
    xmlgen = super.xmlgen.overrideCabal (drv: { doCheck = false; });
    xml-html-conduit-lens = super.xml-html-conduit-lens.overrideCabal (drv: { jailbreak = true; });
    xml-lens = super.xml-lens.overrideCabal (drv: { jailbreak = true; });
    xmonad-extras = super.xmonad-extras.overrideCabal (drv: { jailbreak = true; });
    xournal-types = super.xournal-types.overrideCabal (drv: { jailbreak = true; });
    yap = super.yap.overrideCabal (drv: { jailbreak = true; });
    yesod-core = super.yesod-core.overrideCabal (drv: { jailbreak = true; });
    yesod-static = super.yesod-static.overrideCabal (drv: { doCheck = false; });
    yst = super.yst.overrideCabal (drv: { jailbreak = true; });
    zeromq3-haskell = super.zeromq3-haskell.overrideCabal (drv: { doCheck = false; });
    zip-archive = super.zip-archive.overrideCabal (drv: { doCheck = false; });
    zlib-conduit = super.zlib-conduit.overrideCabal (drv: { noHaddock = true; });

    # Missing system library mappings
    inherit (pkgs.gnome) gnome_vfs GConf;
  };

in

  fix (extend (extend (extend haskellPackages defaultConfiguration) compatLayer) overrides)
