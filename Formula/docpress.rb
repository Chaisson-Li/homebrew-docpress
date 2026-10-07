class Docpress < Formula
  include Language::Python::Virtualenv

  desc "DocBook CLI: create, validate, build, and publish documents"
  homepage "https://doc.press"
  url "https://files.pythonhosted.org/packages/65/b5/54f8b7039d85b7a5f3c94df5a94b5c08271a5b2c13ca5d0b4f6ed098a6ce/docpress-1.3.0.tar.gz"
  sha256 "3d8aa5fbd9fb60809b2ac8adec1f3e68ab60daa6c69827bc962870f520ef8d7d"
  license "MIT"

  # Pango's shared libraries. Do not depend on Homebrew's weasyprint formula.
  depends_on "pango"
  depends_on "python@3.12"

  def install
    # Homebrew's pip_install passes --no-deps. This formula installs the
    # published extra, and pip fetches that extra's dependencies from PyPI.
    virtualenv_create(libexec, "python3.12", system_site_packages: false)
    python3 = Formula["python@3.12"].opt_bin/"python3.12"
    system python3, "-m", "pip", "--python=#{libexec}/bin/python", "install",
           "--disable-pip-version-check", "docpress[pdf]==#{version}"

    # HOMEBREW_PREFIX is /opt/homebrew on Apple Silicon and /usr/local on Intel.
    (bin/"docpress").write <<~SH
      #!/bin/bash
      export DYLD_FALLBACK_LIBRARY_PATH="#{HOMEBREW_PREFIX}/lib${DYLD_FALLBACK_LIBRARY_PATH:+:$DYLD_FALLBACK_LIBRARY_PATH}"
      exec "#{libexec}/bin/docpress" "$@"
    SH
    chmod 0755, bin/"docpress"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/docpress --version")
  end
end
