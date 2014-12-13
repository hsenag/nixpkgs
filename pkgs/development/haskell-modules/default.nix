{ pkgs, newScope, stdenv, fetchurl, ghc, overrides ? (self: super: {}) }:

let

  fix = f: let x = f x // { __unfix__ = f; }; in x;

  extend = rattrs: f: self: let super = rattrs self; in super // f self super;

  haskellPackages = self:
    let

      buildCabal_ = pkgs.callPackage ./generic-builder.nix {
        inherit stdenv ghc fetchurl;
        inherit (pkgs) pkgconfig glibcLocales coreutils gnugrep gnused;
        inherit (self) jailbreakCabal;
      };

      buildCabal = args: stdenv.lib.addPassthru (buildCabal_ args) { overrideArgs = f: buildCabal (args // (f args)); };

      definePackage = args: pkg: newScope self pkg args;

    in
      import ./hackage-packages.nix { inherit stdenv ghc pkgs definePackage; } // {

        inherit ghc buildCabal;

        mtl21 = definePackage {}
                ({ buildCabal, transformers }:
                 buildCabal {
                   pname = "mtl";
                   version = "2.1.3.1";
                   sha256 = "1xpn2wjmqbh2cg1yssc6749xpgcqlrrg4iilwqgkcjgvaxlpdbvp";
                   buildDepends = [ transformers ];
                   meta = {
                     homepage = "http://github.com/ekmett/mtl";
                     description = "Monad classes, using functional dependencies";
                     license = stdenv.lib.licenses.bsd3;
                     platforms = ghc.meta.platforms;
                   };
                  });

         ghcWithPackages = packages: pkgs.callPackage ../compilers/ghc/with-packages.nix {
           inherit stdenv ghc packages;
         };

      };

  defaultConfiguration = self: super: {
    # Disable GHC 7.8.3 core libraries.
    array = null;
    base = null;
    binary = null;
    binPackageDb = null;
    bytestring = null;
    Cabal = null;
    containers = null;
    deepseq = null;
    directory = null;
    filepath = null;
    ghcPrim = null;
    haskeline = null;
    haskell2010 = null;
    haskell98 = null;
    hoopl = null;
    hpc = null;
    integerGmp = null;
    oldLocale = null;
    oldTime = null;
    pretty = null;
    process = null;
    rts = null;
    templateHaskell = null;
    terminfo = null;
    time = null;
    transformers = null;
    unix = null;
    xhtml = null;

    # Break infinite recursions.
    curl = super.curl.override { inherit (pkgs) curl; };
    gnutls = super.gnutls.override { inherit (pkgs) gnutls; };
    gsasl = super.gsasl.override { inherit (pkgs) gsasl; };
    sqlite = super.sqlite.override { inherit (pkgs) sqlite; };
    zlib = super.zlib.override { inherit (pkgs) zlib; };
    digest = super.digest.override { inherit (pkgs) zlib; };

    # We cannot use mtl 2.2.x with GHC versions < 7.9.x.
    mtl22 = super.mtl.override { transformers = super.transformers; };
    mtl = self.mtl21.override { transformers = null; };

    # transformers-compat doesn't auto-detect the correct flags for
    # building with transformers 0.3.x.
    transformersCompat = super.transformersCompat.overrideArgs (drv: { configureFlags = ["-fthree"] ++ drv.configureFlags or []; });

    # Doesn't compile with lua 5.2.
    hslua = super.hslua.override { lua = pkgs.lua5_1; };

    # These packages fail their test suite.
    networkUri = super.networkUri.overrideArgs (drv: { doCheck = false; });

    /* doCheck = false;
    postgresql-simple
    llvm-general-pure
    time
    setenv
    hspec-expectations
    crypto-conduit
    bitset
    dbus
    llvm-general
    hspec
    warp
    hsbencher-fusion
    process-conduit
    command-qq
    http-client
    doctest
    hashed-storage
    math-functions
    hindent
    GLFW-b
    aws
    CouchDB
    grid
    dom-selector
    HTTP
    th-desugar
    amqp
    simple-sendfile
    ghc-events
    sparse
    pipes-binary
    haskoin
    conduit
    stm-containers
    http-conduit
    pandoc
    xmlgen
    cmdtheline
    hsbencher
    network-uri
    distributed-process-platform
    permutation
    fb
    bson
    haskell-names
    handa-gdata
    serialport
    js-jquery
    tls
    nanospec
    haskell-src-exts
    monad-par
    mwc-random
    crypto-numbers
    punycode
    http-client-tls
    directory-layout
    rethinkdb
    equivalence
    thread-local-storage
    filestore
    RSA
    hedis
    vty
    rematch
    http-reverse-proxy
    system-filepath
    lifted-base
    boundingboxes
    network-transport-tcp
    ariadne
    language-ecmascript
    thyme
    hledger-web
    text
    bindings-GLFW
    ghc-mod
    options
    holy-project
    criterion
    opaleye
    pipes-shell
    base64-bytestring
    pandoc-citeproc
    concreteTyperep
    scotty
    wreq
    HList
    hspec-meta
    Cabal
    HTF
    Rasterific
    asn1-encoding
    webdriver
    deepseq-th
    linear
    cuda
    threads
    hashable
    language-java
    yesod-static
    happstack-server.nix
    uuid
    zeromq3-haskell
    http-streams
    statistics
    conduit-extra
    wai-logger
    libjenkins
    graphviz
    snowball
    twitter-types
    hi
    fsnotify
    unordered-containers
    zip-archive
    MissingH
    cautious-file
    abstract-deque
    cabal-bounds
    haskell-docs
    ghcid
    ihaskell
    cabal-meta
    */

    # Missing system library mappings
    Advapi32 = null;
    CEGUIBase = null;
    CEGUIOgreRenderer = null;
    EGL = null;
    GConf = null;
    GLESv2 = null;
    GeoIP = null;
    GraphicsMagick = null;
    HGamer3DCAudio015 = null;
    HGamer3DOIS015 = null;
    HTam = null;
    ImageMagick = null;
    Imlib2 = null;
    Judy = null;
    K8055D = null;
    LEXER = null;
    MagickCore = null;
    MagickWand = null;
    OGRE = null;
    OIS = null;
    OgreMain = null;
    OgrePaging = null;
    OgreProperty = null;
    OgreRTShaderSystem = null;
    OgreTerrain = null;
    OpenNI2 = null;
    Qt5Core = null;
    Qt5Gui = null;
    Qt5Qml = null;
    Qt5Quick = null;
    Qt5Widgets = null;
    QtCore = null;
    QtWebKit = null;
    QuadProgpp = null;
    SDL2_ttf = null;
    Synt = null;
    UniqueLogicNP = null;
    Xdamage = null;
    Xfixes = null;
    Xinerama = null;
    accelerateLlvm = null;
    accelerateLlvmMultidev = null;
    accelerateLlvmNative = null;
    accelerateLlvmPtx = null;
    advapi32 = null;
    aether = null;
    alut = null;
    antlr3c = null;
    appindicator = null;
    appindicator3 = null;
    applicative = null;
    apr-1 = null;
    apr-util-1 = null;
    arbb_dev = null;
    b2 = null;
    bfd = null;
    blkid = null;
    bluetooth = null;
    cabal-install = self.cabalInstall;
    camwire_1394 = null;
    canlib = null;
    casadi_control = null;
    casadi_core = null;
    casadi_ipopt_interface = null;
    casadi_snopt_interface = null;
    cblas = null;
    cgenHs = null;
    clntsh = null;
    cmph = null;
    codec2 = null;
    com_err = null;
    comctl32 = null;
    comdlg32 = null;
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
    dc1394 = null;
    dc1394_control = null;
    debianMirror = null;
    dns_sd = null;
    doublefann = null;
    dsound = null;
    dttools = null;
    easyData = null;
    eibclient = null;
    eng = null;
    epd = null;
    eskit = null;
    esound = null;
    ev = null;
    event = null;
    f77blas = null;
    fann = null;
    fftw3 = null;
    fltk = null;
    fltk_images = null;
    fmodex = null;
    freenect_sync = null;
    friso = null;
    ftd2xx = null;
    g = null;
    gcc_s = null;
    gcrypt = null;
    gdi32 = null;
    gdk_x11 = null;
    gecodeint = null;
    gecodekernel = null;
    gecodesearch = null;
    gecodeset = null;
    gecodesupport = null;
    ghcjsBase = null;
    gnome-vfs = null;
    gnomeVfsModule = null;
    gnome_keyring = null;
    gomp = null;
    grgen = null;
    groonga = null;
    gstreamer-audio = null;
    gstreamer-base = null;
    gstreamer-controller = null;
    gstreamer-dataprotocol = null;
    gstreamer-net = null;
    gstreamer-plugins-base = null;
    gtk-mac-integration = null;
    gtkC = null;
    gtk_x11 = null;
    gtksourceview = null;
    hasteLib = null;
    help = null;
    hg3dcegui040 = null;
    hg3denet040 = null;
    hg3dogre040 = null;
    hg3dsdl2040 = null;
    hg3dsfml040 = null;
    hsqlOracle = null;
    hsqlSqlite = null;
    hyperestraier = null;
    hyperleveldb = null;
    ige-mac-integration = null;
    imm32 = null;
    instanceControl = null;
    integer = null;
    integerSimple = null;
    intel_aes = null;
    jvm = null;
    kernel32 = null;
    kics = null;
    languageCssAttoparsec = null;
    lapack = null;
    lapacke = null;
    lber = null;
    lbfgsb = null;
    ldap = null;
    leksahDummy = null;
    leksahMain = null;
    leksahPluginPane = null;
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
    llvmConfig = null;
    mozembed = null;
    mpdec = null;
    mpi = null;
    msimg32 = null;
    mx = null;
    mysqlConfig = null;
    mysqlclient = null;
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
    ovr = null;
    pHash = null;
    papi = null;
    pfs = null;
    pkgs_tzdata = null;
    plplotd-gnome2 = null;
    poker-eval = null;
    popplerGlib = null;
    pulse-simple = null;
    qdbm = null;
    quickcheckLioInstances = null;
    rados = null;
    raptor = null;
    raw1394 = null;
    rdkafka = null;
    resolv = null;
    riakBump = null;
    rocksdb = null;
    rt = null;
    scsynth = null;
    sedna = null;
    sfml-audio = null;
    sfml-network = null;
    sfml-system = null;
    sfml-window = null;
    shell32 = null;
    shfolder = null;
    sipc = null;
    sixense = null;
    sqlplus = null;
    ssh2 = null;
    statsWeb = null;
    stringTemplates = null;
    swipl = null;
    systemGraphviz = null;
    systemd-daemon = null;
    tag_c = null;
    taglib_c = null;
    terralib4c = null;
    theora = null;
    tiff = null;
    translib = null;
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
    wwwMinus = null;
    xau = null;
    xenctrl = null;
    xerces-c = null;
    xmmsclient = null;
    xmmsclient-glib = null;
    xqilla = null;
    zephyr = null;
    zeromq = null;
    zookeeper_mt = null;

  };

in

  fix (extend (extend haskellPackages defaultConfiguration) overrides)
