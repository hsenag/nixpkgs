{ pkgs, newScope, stdenv, fetchurl, ghc, overrides ? (self: super: {}) }:

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
        overrideArgs = f: mkDerivation (args // (f args));
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

         ghcWithPackages = packages: pkgs.callPackage ../compilers/ghc/with-packages.nix {
           inherit stdenv ghc packages;
         };

      };

  compatLayer = import ./compat-layer.nix;

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

    # We cannot use mtl 2.2.x with GHC versions < 7.9.x.
    mtl22 = super.mtl.override { transformers = super.transformers; };
    mtl = self.mtl21.override { transformers = null; };

    # transformers-compat doesn't auto-detect the correct flags for
    # building with transformers 0.3.x.
    transformers-compat = super.transformers-compat.overrideArgs (drv: { configureFlags = ["-fthree"] ++ drv.configureFlags or []; });

    # Doesn't compile with lua 5.2.
    hslua = super.hslua.override { lua = pkgs.lua5_1; };

    abstract-deque = super.abstract-deque.overrideArgs (drv: { doCheck = false; });
    accelerate-cuda = super.accelerate-cuda.overrideArgs (drv: { jailbreak = true; });
    accelerate = super.accelerate.overrideArgs (drv: { jailbreak = true; });
    active = super.active.overrideArgs (drv: { jailbreak = true; });
    aeson-utils = super.aeson-utils.overrideArgs (drv: { jailbreak = true; });
    Agda = super.Agda.overrideArgs (drv: { jailbreak = true; noHaddock = true; });
    amqp = super.amqp.overrideArgs (drv: { doCheck = false; });
    arbtt = super.arbtt.overrideArgs (drv: { jailbreak = true; });
    ariadne = super.ariadne.overrideArgs (drv: { doCheck = false; });
    arithmoi = super.arithmoi.overrideArgs (drv: { jailbreak = true; });
    asn1-encoding = super.asn1-encoding.overrideArgs (drv: { doCheck = false; });
    assert-failure = super.assert-failure.overrideArgs (drv: { jailbreak = true; });
    atto-lisp = super.atto-lisp.overrideArgs (drv: { jailbreak = true; });
    attoparsec-conduit = super.attoparsec-conduit.overrideArgs (drv: { noHaddock = true; });
    authenticate-oauth = super.authenticate-oauth.overrideArgs (drv: { jailbreak = true; });
    aws = super.aws.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    base64-bytestring = super.base64-bytestring.overrideArgs (drv: { doCheck = false; });
    benchpress = super.benchpress.overrideArgs (drv: { jailbreak = true; });
    binary-conduit = super.binary-conduit.overrideArgs (drv: { jailbreak = true; });
    bindings-GLFW = super.bindings-GLFW.overrideArgs (drv: { doCheck = false; });
    bitset = super.bitset.overrideArgs (drv: { doCheck = false; });
    blaze-builder-conduit = super.blaze-builder-conduit.overrideArgs (drv: { noHaddock = true; });
    blaze-builder-enumerator = super.blaze-builder-enumerator.overrideArgs (drv: { jailbreak = true; });
    blaze-svg = super.blaze-svg.overrideArgs (drv: { jailbreak = true; });
    boundingboxes = super.boundingboxes.overrideArgs (drv: { doCheck = false; });
    bson = super.bson.overrideArgs (drv: { doCheck = false; });
    bytestring-progress = super.bytestring-progress.overrideArgs (drv: { noHaddock = true; });
    cabal2ghci = super.cabal2ghci.overrideArgs (drv: { jailbreak = true; });
    cabal-bounds = super.cabal-bounds.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    cabal-cargs = super.cabal-cargs.overrideArgs (drv: { jailbreak = true; });
    cabal-lenses = super.cabal-lenses.overrideArgs (drv: { jailbreak = true; });
    cabal-macosx = super.cabal-macosx.overrideArgs (drv: { jailbreak = true; });
    cabal-meta = super.cabal-meta.overrideArgs (drv: { doCheck = false; });
    cairo = super.cairo.overrideArgs (drv: { jailbreak = true; });
    cautious-file = super.cautious-file.overrideArgs (drv: { doCheck = false; });
    certificate = super.certificate.overrideArgs (drv: { jailbreak = true; });
    Chart-cairo = super.Chart-cairo.overrideArgs (drv: { jailbreak = true; });
    Chart-diagrams = super.Chart-diagrams.overrideArgs (drv: { jailbreak = true; });
    Chart = super.Chart.overrideArgs (drv: { jailbreak = true; });
    ChasingBottoms = super.ChasingBottoms.overrideArgs (drv: { jailbreak = true; });
    cheapskate = super.cheapskate.overrideArgs (drv: { jailbreak = true; });
    citeproc-hs = super.citeproc-hs.overrideArgs (drv: { jailbreak = true; });
    clay = super.clay.overrideArgs (drv: { jailbreak = true; });
    cmdtheline = super.cmdtheline.overrideArgs (drv: { doCheck = false; });
    codex = super.codex.overrideArgs (drv: { jailbreak = true; });
    command-qq = super.command-qq.overrideArgs (drv: { doCheck = false; });
    comonads-fd = super.comonads-fd.overrideArgs (drv: { noHaddock = true; });
    comonad-transformers = super.comonad-transformers.overrideArgs (drv: { noHaddock = true; });
    concreteTyperep = super.concreteTyperep.overrideArgs (drv: { doCheck = false; });
    conduit-extra = super.conduit-extra.overrideArgs (drv: { doCheck = false; });
    conduit = super.conduit.overrideArgs (drv: { doCheck = false; });
    CouchDB = super.CouchDB.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    criterion = super.criterion.overrideArgs (drv: { doCheck = false; });
    crypto-conduit = super.crypto-conduit.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    crypto-numbers = super.crypto-numbers.overrideArgs (drv: { doCheck = false; });
    cuda = super.cuda.overrideArgs (drv: { doCheck = false; });
    data-accessor = super.data-accessor.overrideArgs (drv: { jailbreak = true; });
    dataenc = super.dataenc.overrideArgs (drv: { jailbreak = true; });
    data-fin = super.data-fin.overrideArgs (drv: { jailbreak = true; });
    data-lens = super.data-lens.overrideArgs (drv: { jailbreak = true; });
    data-pprint = super.data-pprint.overrideArgs (drv: { jailbreak = true; });
    dbmigrations = super.dbmigrations.overrideArgs (drv: { jailbreak = true; });
    dbus = super.dbus.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    deepseq-th = super.deepseq-th.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    diagrams-contrib = super.diagrams-contrib.overrideArgs (drv: { jailbreak = true; });
    diagrams-core = super.diagrams-core.overrideArgs (drv: { jailbreak = true; });
    diagrams-lib = super.diagrams-lib.overrideArgs (drv: { jailbreak = true; });
    diagrams-postscript = super.diagrams-postscript.overrideArgs (drv: { jailbreak = true; });
    diagrams-rasterific = super.diagrams-rasterific.overrideArgs (drv: { jailbreak = true; });
    diagrams = super.diagrams.overrideArgs (drv: { noHaddock = true; jailbreak = true; });
    diagrams-svg = super.diagrams-svg.overrideArgs (drv: { jailbreak = true; });
    digestive-functors-heist = super.digestive-functors-heist.overrideArgs (drv: { jailbreak = true; });
    digestive-functors-snap = super.digestive-functors-snap.overrideArgs (drv: { jailbreak = true; });
    digestive-functors = super.digestive-functors.overrideArgs (drv: { jailbreak = true; });
    directory-layout = super.directory-layout.overrideArgs (drv: { doCheck = false; });
    distributed-process-platform = super.distributed-process-platform.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    distributed-process = super.distributed-process.overrideArgs (drv: { jailbreak = true; });
    doctest = super.doctest.overrideArgs (drv: { noHaddock = true; doCheck = false; });
    dom-selector = super.dom-selector.overrideArgs (drv: { doCheck = false; });
    download-curl = super.download-curl.overrideArgs (drv: { jailbreak = true; });
    dual-tree = super.dual-tree.overrideArgs (drv: { jailbreak = true; });
    either = super.either.overrideArgs (drv: { noHaddock = true; });
    ekg = super.ekg.overrideArgs (drv: { jailbreak = true; });
    elm-get = super.elm-get.overrideArgs (drv: { jailbreak = true; });
    elm-server = super.elm-server.overrideArgs (drv: { jailbreak = true; });
    encoding = super.encoding.overrideArgs (drv: { jailbreak = true; });
    enummapset = super.enummapset.overrideArgs (drv: { jailbreak = true; });
    equational-reasoning = super.equational-reasoning.overrideArgs (drv: { jailbreak = true; });
    equivalence = super.equivalence.overrideArgs (drv: { doCheck = false; });
    errors = super.errors.overrideArgs (drv: { jailbreak = true; });
    extensible-effects = super.extensible-effects.overrideArgs (drv: { jailbreak = true; });
    failure = super.failure.overrideArgs (drv: { jailbreak = true; });
    fay = super.fay.overrideArgs (drv: { jailbreak = true; });
    fb = super.fb.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    filestore = super.filestore.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    force-layout = super.force-layout.overrideArgs (drv: { jailbreak = true; });
    free-game = super.free-game.overrideArgs (drv: { jailbreak = true; });
    free = super.free.overrideArgs (drv: { jailbreak = true; });
    fsnotify = super.fsnotify.overrideArgs (drv: { doCheck = false; });
    ghc-events = super.ghc-events.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    ghcid = super.ghcid.overrideArgs (drv: { doCheck = false; });
    ghc-mod = super.ghc-mod.overrideArgs (drv: { doCheck = false; });
    gitit = super.gitit.overrideArgs (drv: { jailbreak = true; });
    glade = super.glade.overrideArgs (drv: { jailbreak = true; });
    GLFW-b = super.GLFW-b.overrideArgs (drv: { doCheck = false; });
    gloss-raster = super.gloss-raster.overrideArgs (drv: { jailbreak = true; });
    gl = super.gl.overrideArgs (drv: { noHaddock = true; });
    gnuplot = super.gnuplot.overrideArgs (drv: { jailbreak = true; });
    Graphalyze = super.Graphalyze.overrideArgs (drv: { jailbreak = true; });
    graphviz = super.graphviz.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    grid = super.grid.overrideArgs (drv: { doCheck = false; });
    groupoids = super.groupoids.overrideArgs (drv: { noHaddock = true; });
    gtk-traymanager = super.gtk-traymanager.overrideArgs (drv: { jailbreak = true; });
    hakyll = super.hakyll.overrideArgs (drv: { jailbreak = true; });
    hamlet = super.hamlet.overrideArgs (drv: { noHaddock = true; });
    handa-gdata = super.handa-gdata.overrideArgs (drv: { doCheck = false; });
    HandsomeSoup = super.HandsomeSoup.overrideArgs (drv: { jailbreak = true; });
    happstack-server = super.happstack-server.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    hashable = super.hashable.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    hashed-storage = super.hashed-storage.overrideArgs (drv: { doCheck = false; });
    haskeline = super.haskeline.overrideArgs (drv: { jailbreak = true; });
    haskell-docs = super.haskell-docs.overrideArgs (drv: { doCheck = false; });
    haskell-names = super.haskell-names.overrideArgs (drv: { doCheck = false; });
    haskell-src-exts = super.haskell-src-exts.overrideArgs (drv: { doCheck = false; });
    haskell-src-meta = super.haskell-src-meta.overrideArgs (drv: { jailbreak = true; });
    haskoin = super.haskoin.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    hasktags = super.hasktags.overrideArgs (drv: { jailbreak = true; });
    haste-compiler = super.haste-compiler.overrideArgs (drv: { noHaddock = true; });
    haxl = super.haxl.overrideArgs (drv: { jailbreak = true; });
    HaXml = super.HaXml.overrideArgs (drv: { noHaddock = true; });
    haxr = super.haxr.overrideArgs (drv: { jailbreak = true; });
    hcltest = super.hcltest.overrideArgs (drv: { jailbreak = true; });
    HDBC-odbc = super.HDBC-odbc.overrideArgs (drv: { noHaddock = true; });
    hedis = super.hedis.overrideArgs (drv: { doCheck = false; });
    heist = super.heist.overrideArgs (drv: { jailbreak = true; });
    hindent = super.hindent.overrideArgs (drv: { doCheck = false; });
    hi = super.hi.overrideArgs (drv: { doCheck = false; });
    hjsmin = super.hjsmin.overrideArgs (drv: { jailbreak = true; });
    hledger-web = super.hledger-web.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    HList = super.HList.overrideArgs (drv: { doCheck = false; });
    hoauth2 = super.hoauth2.overrideArgs (drv: { jailbreak = true; });
    holy-project = super.holy-project.overrideArgs (drv: { doCheck = false; });
    hoodle-core = super.hoodle-core.overrideArgs (drv: { noHaddock = true; });
    hsbencher-fusion = super.hsbencher-fusion.overrideArgs (drv: { doCheck = false; });
    hsbencher = super.hsbencher.overrideArgs (drv: { doCheck = false; });
    hsc3-db = super.hsc3-db.overrideArgs (drv: { noHaddock = true; });
    hsimport = super.hsimport.overrideArgs (drv: { jailbreak = true; });
    hsini = super.hsini.overrideArgs (drv: { jailbreak = true; });
    hspec-discover = super.hspec-discover.overrideArgs (drv: { noHaddock = true; });
    hspec-expectations = super.hspec-expectations.overrideArgs (drv: { doCheck = false; });
    hspec-meta = super.hspec-meta.overrideArgs (drv: { doCheck = false; });
    hspec = super.hspec.overrideArgs (drv: { doCheck = false; });
    hsyslog = super.hsyslog.overrideArgs (drv: { noHaddock = true; });
    HTF = super.HTF.overrideArgs (drv: { doCheck = false; });
    http-attoparsec = super.http-attoparsec.overrideArgs (drv: { jailbreak = true; });
    http-client-conduit = super.http-client-conduit.overrideArgs (drv: { noHaddock = true; });
    http-client-multipart = super.http-client-multipart.overrideArgs (drv: { noHaddock = true; });
    http-client = super.http-client.overrideArgs (drv: { doCheck = false; });
    http-client-tls = super.http-client-tls.overrideArgs (drv: { doCheck = false; });
    http-conduit = super.http-conduit.overrideArgs (drv: { doCheck = false; });
    httpd-shed = super.httpd-shed.overrideArgs (drv: { jailbreak = true; });
    http-reverse-proxy = super.http-reverse-proxy.overrideArgs (drv: { doCheck = false; });
    http-streams = super.http-streams.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    HTTP = super.HTTP.overrideArgs (drv: { doCheck = false; noHaddock = true; });
    http-types = super.http-types.overrideArgs (drv: { jailbreak = true; });
    idris = super.idris.overrideArgs (drv: { jailbreak = true; });
    ihaskell = super.ihaskell.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    js-jquery = super.js-jquery.overrideArgs (drv: { doCheck = false; });
    json-assertions = super.json-assertions.overrideArgs (drv: { jailbreak = true; });
    json-rpc = super.json-rpc.overrideArgs (drv: { jailbreak = true; });
    json-schema = super.json-schema.overrideArgs (drv: { jailbreak = true; });
    kansas-lava = super.kansas-lava.overrideArgs (drv: { jailbreak = true; });
    keys = super.keys.overrideArgs (drv: { jailbreak = true; });
    language-c-quote = super.language-c-quote.overrideArgs (drv: { jailbreak = true; });
    language-ecmascript = super.language-ecmascript.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    language-java = super.language-java.overrideArgs (drv: { doCheck = false; });
    largeword = super.largeword.overrideArgs (drv: { jailbreak = true; });
    libjenkins = super.libjenkins.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    libsystemd-journal = super.libsystemd-journal.overrideArgs (drv: { jailbreak = true; });
    lifted-base = super.lifted-base.overrideArgs (drv: { doCheck = false; });
    linear = super.linear.overrideArgs (drv: { doCheck = false; });
    ListLike = super.ListLike.overrideArgs (drv: { jailbreak = true; });
    list-tries = super.list-tries.overrideArgs (drv: { jailbreak = true; });
    llvm-general-pure = super.llvm-general-pure.overrideArgs (drv: { doCheck = false; });
    llvm-general = super.llvm-general.overrideArgs (drv: { doCheck = false; });
    lzma-enumerator = super.lzma-enumerator.overrideArgs (drv: { jailbreak = true; });
    machines-directory = super.machines-directory.overrideArgs (drv: { jailbreak = true; });
    machines-io = super.machines-io.overrideArgs (drv: { jailbreak = true; });
    mainland-pretty = super.mainland-pretty.overrideArgs (drv: { jailbreak = true; });
    markdown-unlit = super.markdown-unlit.overrideArgs (drv: { noHaddock = true; });
    math-functions = super.math-functions.overrideArgs (drv: { doCheck = false; });
    MissingH = super.MissingH.overrideArgs (drv: { doCheck = false; });
    MonadCatchIO-mtl = super.MonadCatchIO-mtl.overrideArgs (drv: { jailbreak = true; });
    MonadCatchIO-transformers = super.MonadCatchIO-transformers.overrideArgs (drv: { jailbreak = true; });
    monadloc-pp = super.monadloc-pp.overrideArgs (drv: { jailbreak = true; });
    monad-par = super.monad-par.overrideArgs (drv: { doCheck = false; });
    monoid-extras = super.monoid-extras.overrideArgs (drv: { jailbreak = true; });
    mpppc = super.mpppc.overrideArgs (drv: { jailbreak = true; });
    msgpack = super.msgpack.overrideArgs (drv: { jailbreak = true; });
    multiplate = super.multiplate.overrideArgs (drv: { jailbreak = true; });
    mwc-random = super.mwc-random.overrideArgs (drv: { doCheck = false; });
    mwcRandom = super.mwcRandom.overrideArgs (drv: { doCheck = false; });
    nanospec = super.nanospec.overrideArgs (drv: { doCheck = false; });
    network-carbon = super.network-carbon.overrideArgs (drv: { jailbreak = true; });
    network-conduit = super.network-conduit.overrideArgs (drv: { noHaddock = true; });
    network-simple = super.network-simple.overrideArgs (drv: { jailbreak = true; });
    network-transport-tcp = super.network-transport-tcp.overrideArgs (drv: { doCheck = false; });
    network-transport-tests = super.network-transport-tests.overrideArgs (drv: { jailbreak = true; });
    network-uri = super.network-uri.overrideArgs (drv: { doCheck = false; });
    numeric-prelude = super.numeric-prelude.overrideArgs (drv: { jailbreak = true; });
    ofx = super.ofx.overrideArgs (drv: { jailbreak = true; });
    opaleye = super.opaleye.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    openssl-streams = super.openssl-streams.overrideArgs (drv: { jailbreak = true; });
    options = super.options.overrideArgs (drv: { doCheck = false; });
    optparse-applicative = super.optparse-applicative.overrideArgs (drv: { jailbreak = true; });
    packunused = super.packunused.overrideArgs (drv: { jailbreak = true; });
    pandoc-citeproc = super.pandoc-citeproc.overrideArgs (drv: { doCheck = false; });
    pandoc = super.pandoc.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    parallel-io = super.parallel-io.overrideArgs (drv: { jailbreak = true; });
    parsec = super.parsec.overrideArgs (drv: { jailbreak = true; });
    permutation = super.permutation.overrideArgs (drv: { doCheck = false; });
    persistent-postgresql = super.persistent-postgresql.overrideArgs (drv: { jailbreak = true; });
    persistent-template = super.persistent-template.overrideArgs (drv: { jailbreak = true; });
    pipes-aeson = super.pipes-aeson.overrideArgs (drv: { jailbreak = true; doCheck = false; });
    pipes-binary = super.pipes-binary.overrideArgs (drv: { jailbreak = true; });
    pipes-http = super.pipes-http.overrideArgs (drv: { jailbreak = true; });
    pipes-network = super.pipes-network.overrideArgs (drv: { jailbreak = true; });
    pipes-shell = super.pipes-shell.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    pipes = super.pipes.overrideArgs (drv: { jailbreak = true; });
    pipes-text = super.pipes-text.overrideArgs (drv: { jailbreak = true; });
    pointed = super.pointed.overrideArgs (drv: { jailbreak = true; });
    pointfree = super.pointfree.overrideArgs (drv: { jailbreak = true; });
    postgresql-simple = super.postgresql-simple.overrideArgs (drv: { doCheck = false; });
    process-conduit = super.process-conduit.overrideArgs (drv: { doCheck = false; });
    product-profunctors = super.product-profunctors.overrideArgs (drv: { jailbreak = true; });
    prolog = super.prolog.overrideArgs (drv: { jailbreak = true; });
    punycode = super.punycode.overrideArgs (drv: { doCheck = false; });
    quickcheck-instances = super.quickcheck-instances.overrideArgs (drv: { jailbreak = true; });
    QuickCheck = super.QuickCheck.overrideArgs (drv: { noHaddock = true; });
    Rasterific = super.Rasterific.overrideArgs (drv: { doCheck = false; });
    reactive-banana-wx = super.reactive-banana-wx.overrideArgs (drv: { jailbreak = true; });
    ReadArgs = super.ReadArgs.overrideArgs (drv: { jailbreak = true; });
    reducers = super.reducers.overrideArgs (drv: { jailbreak = true; });
    rematch = super.rematch.overrideArgs (drv: { doCheck = false; });
    repa-algorithms = super.repa-algorithms.overrideArgs (drv: { jailbreak = true; });
    repa-examples = super.repa-examples.overrideArgs (drv: { jailbreak = true; });
    repa-io = super.repa-io.overrideArgs (drv: { jailbreak = true; });
    RepLib = super.RepLib.overrideArgs (drv: { noHaddock = true; });
    rest-core = super.rest-core.overrideArgs (drv: { jailbreak = true; });
    rest-gen = super.rest-gen.overrideArgs (drv: { jailbreak = true; });
    rest-stringmap = super.rest-stringmap.overrideArgs (drv: { jailbreak = true; });
    rest-types = super.rest-types.overrideArgs (drv: { jailbreak = true; });
    rethinkdb = super.rethinkdb.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    retry = super.retry.overrideArgs (drv: { jailbreak = true; });
    rope = super.rope.overrideArgs (drv: { jailbreak = true; });
    RSA = super.RSA.overrideArgs (drv: { doCheck = false; });
    scientific = super.scientific.overrideArgs (drv: { jailbreak = true; });
    scotty = super.scotty.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    sdl2 = super.sdl2.overrideArgs (drv: { noHaddock = true; });
    serialport = super.serialport.overrideArgs (drv: { doCheck = false; });
    setenv = super.setenv.overrideArgs (drv: { doCheck = false; });
    setlocale = super.setlocale.overrideArgs (drv: { jailbreak = true; });
    shakespeare-css = super.shakespeare-css.overrideArgs (drv: { noHaddock = true; });
    shakespeare-i18n = super.shakespeare-i18n.overrideArgs (drv: { noHaddock = true; });
    shakespeare-js = super.shakespeare-js.overrideArgs (drv: { noHaddock = true; });
    shakespeare-text = super.shakespeare-text.overrideArgs (drv: { noHaddock = true; });
    simple-sendfile = super.simple-sendfile.overrideArgs (drv: { doCheck = false; });
    singletons = super.singletons.overrideArgs (drv: { noHaddock = true; });
    skein = super.skein.overrideArgs (drv: { jailbreak = true; });
    snap-core = super.snap-core.overrideArgs (drv: { jailbreak = true; });
    snaplet-acid-state = super.snaplet-acid-state.overrideArgs (drv: { jailbreak = true; });
    snaplet-redis = super.snaplet-redis.overrideArgs (drv: { jailbreak = true; });
    snaplet-stripe = super.snaplet-stripe.overrideArgs (drv: { jailbreak = true; });
    snap-web-routes = super.snap-web-routes.overrideArgs (drv: { jailbreak = true; });
    snowball = super.snowball.overrideArgs (drv: { doCheck = false; });
    sparse = super.sparse.overrideArgs (drv: { doCheck = false; });
    statistics = super.statistics.overrideArgs (drv: { doCheck = false; });
    stm-containers = super.stm-containers.overrideArgs (drv: { doCheck = false; });
    storable-record = super.storable-record.overrideArgs (drv: { jailbreak = true; });
    Strafunski-StrategyLib = super.Strafunski-StrategyLib.overrideArgs (drv: { jailbreak = true; });
    stripe = super.stripe.overrideArgs (drv: { jailbreak = true; });
    symbol = super.symbol.overrideArgs (drv: { jailbreak = true; });
    system-filepath = super.system-filepath.overrideArgs (drv: { doCheck = false; });
    tabular = super.tabular.overrideArgs (drv: { jailbreak = true; });
    tar = super.tar.overrideArgs (drv: { noHaddock = true; });
    template-default = super.template-default.overrideArgs (drv: { jailbreak = true; });
    temporary = super.temporary.overrideArgs (drv: { jailbreak = true; });
    test-framework-quickcheck2 = super.test-framework-quickcheck2.overrideArgs (drv: { jailbreak = true; });
    text = super.text.overrideArgs (drv: { doCheck = false; });
    th-desugar = super.th-desugar.overrideArgs (drv: { doCheck = false; });
    these = super.these.overrideArgs (drv: { jailbreak = true; });
    th-lift-instances = super.th-lift-instances.overrideArgs (drv: { jailbreak = true; });
    th-orphans = super.th-orphans.overrideArgs (drv: { jailbreak = true; });
    thread-local-storage = super.thread-local-storage.overrideArgs (drv: { doCheck = false; });
    threads = super.threads.overrideArgs (drv: { doCheck = false; });
    threepenny-gui = super.threepenny-gui.overrideArgs (drv: { jailbreak = true; });
    thyme = super.thyme.overrideArgs (drv: { doCheck = false; });
    timeparsers = super.timeparsers.overrideArgs (drv: { jailbreak = true; });
    tls = super.tls.overrideArgs (drv: { doCheck = false; });
    twitter-types = super.twitter-types.overrideArgs (drv: { doCheck = false; });
    unordered-containers = super.unordered-containers.overrideArgs (drv: { doCheck = false; });
    uri-encode = super.uri-encode.overrideArgs (drv: { jailbreak = true; });
    usb = super.usb.overrideArgs (drv: { jailbreak = true; });
    utf8-string = super.utf8-string.overrideArgs (drv: { noHaddock = true; });
    uuid = super.uuid.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    vacuum-graphviz = super.vacuum-graphviz.overrideArgs (drv: { jailbreak = true; });
    vault = super.vault.overrideArgs (drv: { jailbreak = true; });
    vcswrapper = super.vcswrapper.overrideArgs (drv: { jailbreak = true; });
    vty = super.vty.overrideArgs (drv: { doCheck = false; });
    vty-ui = super.vty-ui.overrideArgs (drv: { jailbreak = true; });
    wai-extra = super.wai-extra.overrideArgs (drv: { jailbreak = true; });
    wai-logger = super.wai-logger.overrideArgs (drv: { doCheck = false; });
    wai-middleware-static = super.wai-middleware-static.overrideArgs (drv: { jailbreak = true; });
    wai-test = super.wai-test.overrideArgs (drv: { noHaddock = true; });
    wai-websockets = super.wai-websockets.overrideArgs (drv: { jailbreak = true; });
    warp = super.warp.overrideArgs (drv: { doCheck = false; });
    webdriver = super.webdriver.overrideArgs (drv: { doCheck = false; jailbreak = true; });
    websockets-snap = super.websockets-snap.overrideArgs (drv: { jailbreak = true; });
    websockets = super.websockets.overrideArgs (drv: { jailbreak = true; });
    wl-pprint-terminfo = super.wl-pprint-terminfo.overrideArgs (drv: { jailbreak = true; });
    wl-pprint-text = super.wl-pprint-text.overrideArgs (drv: { jailbreak = true; });
    wreq = super.wreq.overrideArgs (drv: { doCheck = false; });
    wxc = super.wxc.overrideArgs (drv: { noHaddock = true; });
    wxdirect = super.wxdirect.overrideArgs (drv: { jailbreak = true; });
    xdot = super.xdot.overrideArgs (drv: { jailbreak = true; });
    xml-conduit = super.xml-conduit.overrideArgs (drv: { jailbreak = true; });
    xmlgen = super.xmlgen.overrideArgs (drv: { doCheck = false; });
    xml-html-conduit-lens = super.xml-html-conduit-lens.overrideArgs (drv: { jailbreak = true; });
    xml-lens = super.xml-lens.overrideArgs (drv: { jailbreak = true; });
    xmonad-extras = super.xmonad-extras.overrideArgs (drv: { jailbreak = true; });
    xournal-types = super.xournal-types.overrideArgs (drv: { jailbreak = true; });
    yap = super.yap.overrideArgs (drv: { jailbreak = true; });
    yesod-core = super.yesod-core.overrideArgs (drv: { jailbreak = true; });
    yesod-static = super.yesod-static.overrideArgs (drv: { doCheck = false; });
    yst = super.yst.overrideArgs (drv: { jailbreak = true; });
    zeromq3-haskell = super.zeromq3-haskell.overrideArgs (drv: { doCheck = false; });
    zip-archive = super.zip-archive.overrideArgs (drv: { doCheck = false; });
    zlib-conduit = super.zlib-conduit.overrideArgs (drv: { noHaddock = true; });

    # Missing system library mappings
    inherit (pkgs.gnome) gnome_vfs GConf;

    accelerate-llvm-multidev = null;
    accelerate-llvm-native = null;
    accelerate-llvm = null;
    accelerate-llvm-ptx = null;
    advapi32 = null;
    Advapi32 = null;
    aether = null;
    alut = null;
    antlr3c = null;
    appindicator3 = null;
    appindicator = null;
    applicative = null;
    apr-1 = null;
    apr-util-1 = null;
    arbb_dev = null;
    b2 = null;
    bfd = null;
    blkid = null;
    bluetooth = null;
    camwire_1394 = null;
    canlib = null;
    casadi_control = null;
    casadi_core = null;
    casadi_ipopt_interface = null;
    casadi_snopt_interface = null;
    cblas = null;
    CEGUIBase = null;
    CEGUIOgreRenderer = null;
    cgen-hs = null;
    clntsh = null;
    cmph = null;
    codec2 = null;
    comctl32 = null;
    comdlg32 = null;
    com_err = null;
    crypto = null;
    csfml-audio = null;
    csfml-graphics = null;
    csfml-network = null;
    csfml-system = null;
    csfml-window = null;
    csound64 = null;
    cudd = null;
    curses = null;
    cusparse = null;
    cwiid = null;
    d3d9 = null;
    d3dx9 = null;
    dbxml = null;
    dc1394_control = null;
    dc1394 = null;
    debian-mirror = null;
    dns_sd = null;
    doublefann = null;
    dsound = null;
    dttools = null;
    easy-data = null;
    EGL = null;
    eibclient = null;
    eng = null;
    epd = null;
    eskit = null;
    esound = null;
    event = null;
    ev = null;
    f77blas = null;
    fann = null;
    fftw3 = null;
    fltk_images = null;
    fltk = null;
    fmodex64 = null;
    fmodex = null;
    freenect_sync = null;
    friso = null;
    ftd2xx = null;
    gcc_s = null;
    gcrypt = null;
    gdi32 = null;
    gdk_x11 = null;
    gecodeint = null;
    gecodekernel = null;
    gecodesearch = null;
    gecodeset = null;
    gecodesupport = null;
    GeoIP = null;
    ghcjs-base = null;
    GLESv2 = null;
    gnome_keyring = null;
    gnome_vfs_module = null;
    gnomeVfsModule = null;
    gnome-vfs = null;
    g = null;
    gomp = null;
    GraphicsMagick = null;
    grgen = null;
    groonga = null;
    gstreamer-audio = null;
    gstreamer-base = null;
    gstreamer-controller = null;
    gstreamer-dataprotocol = null;
    gstreamer-net = null;
    gstreamer-plugins-base = null;
    gtkC = null;
    gtk-mac-integration = null;
    gtksourceview = null;
    gtk_x11 = null;
    haste-lib = null;
    hasteLib = null;
    help = null;
    hg3dcegui040 = null;
    hg3denet040 = null;
    hg3dogre040 = null;
    hg3dsdl2040 = null;
    hg3dsfml040 = null;
    HGamer3DCAudio015 = null;
    HGamer3DOIS015 = null;
    hsql-oracle = null;
    hsql-sqlite = null;
    HTam = null;
    hyperestraier = null;
    hyperleveldb = null;
    ige-mac-integration = null;
    ImageMagick = null;
    Imlib2 = null;
    imm32 = null;
    instance-control = null;
    integer = null;
    integer-simple = null;
    intel_aes = null;
    Judy = null;
    jvm = null;
    K8055D = null;
    kernel32 = null;
    kics = null;
    language-css-attoparsec = null;
    lapacke = null;
    lapack = null;
    lber = null;
    lbfgsb = null;
    ldap = null;
    leksah-dummy = null;
    leksah-main = null;
    leksah-plugin-pane = null;
    LEXER = null;
    libaosd = null;
    libavcodec = null;
    libavformat = null;
    libavutil = null;
    libc = null;
    libdpkg = null;
    libglade = null;
    libkmod = null;
    libnm-glib = null;
    librrd = null;
    libsoup_gnome = null;
    libswscale = null;
    libsystemd-daemon = null;
    libudev = null;
    libxfconf-0 = null;
    libxine = null;
    llvm-config = null;
    MagickCore = null;
    MagickWand = null;
    mozembed = null;
    mpdec = null;
    mpi = null;
    msimg32 = null;
    mx = null;
    mysqlclient = null;
    mysqlConfig = null;
    netsnmp = null;
    newrelic-collector-client = null;
    newrelic-common = null;
    newrelic-transaction = null;
    nm-glib = null;
    notify = null;
    nsl = null;
    nvidia_x11 = null;
    nvvm = null;
    objc = null;
    odbc = null;
    ogg = null;
    OgreMain = null;
    OGRE = null;
    OgrePaging = null;
    OgreProperty = null;
    OgreRTShaderSystem = null;
    OgreTerrain = null;
    OIS = null;
    ole32 = null;
    oleaut32 = null;
    opcodes = null;
    opencc = null;
    opencv_calib3d = null;
    opencv_contrib = null;
    opencv_core = null;
    opencv_features2d = null;
    opencv_flann = null;
    opencv_gpu = null;
    opencv_highgui = null;
    opencv_imgproc = null;
    opencv_legacy = null;
    opencv_ml = null;
    opencv_objdetect = null;
    opencv_video = null;
    OpenNI2 = null;
    ovr = null;
    papi = null;
    pfs = null;
    pHash = null;
    pkgs_tzdata = null;
    plplotd-gnome2 = null;
    poker-eval = null;
    popplerGlib = null;
    pulse-simple = null;
    qdbm = null;
    Qt5Core = null;
    Qt5Gui = null;
    Qt5Qml = null;
    Qt5Quick = null;
    Qt5Widgets = null;
    QtCore = null;
    QtWebKit = null;
    QuadProgpp = null;
    quickcheck-lio-instances = null;
    rados = null;
    raptor = null;
    raw1394 = null;
    rdkafka = null;
    resolv = null;
    riak-bump = null;
    rocksdb = null;
    rt = null;
    scsynth = null;
    SDL2_ttf = null;
    sedna = null;
    sfml-audio = null;
    sfml-network = null;
    sfml-system = null;
    sfml-window = null;
    shell32 = null;
    shfolder = null;
    sipc = null;
    sixense = null;
    sixense_x64 = null;
    sqlplus = null;
    ssh2 = null;
    stats-web = null;
    string-templates = null;
    swipl = null;
    Synt = null;
    systemd-daemon = null;
    systemGraphviz = null;
    tag_c = null;
    taglib_c = null;
    terralib4c = null;
    theora = null;
    tiff = null;
    translib = null;
    UniqueLogicNP = null;
    user32 = null;
    util = null;
    virt = null;
    wayland-client = null;
    wayland-cursor = null;
    wayland-egl = null;
    wayland-server = null;
    winmm = null;
    winspool = null;
    wmflite = null;
    ws2_32 = null;
    www-minus = null;
    xau = null;
    Xdamage = null;
    xenctrl = null;
    xerces-c = null;
    Xfixes = null;
    Xinerama = null;
    xmmsclient-glib = null;
    xmmsclient = null;
    xqilla = null;
    zephyr = null;
    zeromq = null;
    zookeeper_mt = null;

  };

in

  fix (extend (extend (extend haskellPackages defaultConfiguration) compatLayer) overrides)
