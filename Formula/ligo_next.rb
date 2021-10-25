class LigoNext < Formula
  desc "Friendly Smart Contract Language for Tezos"
  homepage "https://ligolang.org/"

  version "000f894f41acdc46f88caa7068ee58dc88aa52c8"
  url "https://gitlab.com/ligolang/ligo/-/archive/000f894f41acdc46f88caa7068ee58dc88aa52c8/ligo-000f894f41acdc46f88caa7068ee58dc88aa52c8.tar.gz"
  # Version is autoscanned from url, we don't specify it explicitly because `brew audit` will complain
  # To calculate sha256: 'curl -L --fail <url> | sha256sum'
  sha256 "1ddd1e0bafdad6d83c0ea56f1a535bd073c4f5f3ba8a31e10ca835212e0dc81c"

  build_dependencies = %w[opam rust hidapi pkg-config]
  build_dependencies.each do |dependency|
    depends_on dependency => :build
  end

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
    ENV["LIGO_VERSION"] = LigoNext.version
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