class Ligo < Formula
  desc "Friendly Smart Contract Language for Tezos"
  homepage "https://ligolang.org/"

  url "https://gitlab.com/ligolang/ligo/-/archive/0.27.0/ligo-0.27.0.tar.gz"
  # Version is autoscanned from url, we don't specify it explicitly because `brew audit` will complain
  # To calculate sha256: 'curl -L --fail <url> | sha256sum'
  sha256 "42c99f442c116959f8d16957462922c0197aa5b98c357ff7523ae129aee6273e"

  bottle do
    root_url "https://github.com/ligolang/homebrew-ligo/releases/download/v#{Ligo.version}"
    # sha256 cellar: :any, catalina: "00d98308f7728e22be22115aaa2b6e0d7bd21fd3788276c0fc28f8371e1c78e5"
    # sha256 cellar: :any, mojave: "72cfb74077e7d50a29132f3549d3e4e2efd38eafd1bd92f5dd29798778d7366e"
  end

  build_dependencies = %w[rust hidapi pkg-config]
  build_dependencies.each do |dependency|
    depends_on dependency => :build
  end

  depends_on "opam" => [:build, "2.0"]

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
