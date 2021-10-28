class Ligo < Formula
  desc "Friendly Smart Contract Language for Tezos"
  homepage "https://ligolang.org/"

  url "https://gitlab.com/ligolang/ligo/-/archive/0.28.0/ligo-0.28.0.tar.gz"
  # Version is autoscanned from url, we don't specify it explicitly because `brew audit` will complain
  # To calculate sha256: 'curl -L --fail <url> | sha256sum'
  sha256 "0c87e303e3ce0ed59897596853f09e3f964981335b5c59ae87c2e0604bda3ba6"

  bottle do
    root_url "https://github.com/ligolang/homebrew-ligo/releases/download/v#{Ligo.version}"
    sha256 cellar: :any, catalina: "00d98308f7728e22be22115aaa2b6e0d7bd21fd3788276c0fc28f8371e1c78e5"
    sha256 cellar: :any, mojave:   "d5ec10af35cac0d283f54553a3fe0cd48af4f0b640979cb2127bad99e2eafa4c"
  end

  build_dependencies = %w[rust hidapi pkg-config]
  build_dependencies.each do |dependency|
    depends_on dependency => :build
  end

  depends_on "opam" => [:build, "2.0.9"]

  dependencies = %w[gmp libev libffi]
  dependencies.each do |dependency|
    depends_on dependency
  end

  # sets up env vars for opam before running a command
  private def with_opam_env(cmd)
    "eval \"$(opam config env)\" && #{cmd}"
  end

  def install
    # ligo version is taken from the environment variable in build-time
    ENV["LIGO_VERSION"] = Ligo.version
    # avoid opam prompts
    ENV["OPAMYES"] = "true"

    # init opam state in ~/.opam
    system "opam", "init", "--bare", "--auto-setup", "--disable-sandboxing"
    # create opam switch with required ocaml version
    system "opam", "switch", "create", ".", "ocaml-base-compiler.4.10.2", "--no-install"
    # build and test external dependencies
    system with_opam_env "opam install --deps-only --with-test --locked ./ligo.opam $(find vendors -name \\*.opam)"
    # build vendored dependencies
    system with_opam_env "opam install $(find vendors -name \\*.opam)"
    # build ligo
    system with_opam_env "dune build -p ligo"

    # install ligo binary
    cp "_build/install/default/bin/ligo", "ligo"
    bin.mkpath
    bin.install "ligo"
  end

  test do
    system "#{bin}/ligo", "--help=plain"
  end
end
