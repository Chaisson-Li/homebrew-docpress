class Docpress < Formula
  include Language::Python::Virtualenv

  desc "DocBook CLI: create, validate, build, and publish documents"
  homepage "https://doc.press"
  url "https://files.pythonhosted.org/packages/0f/d3/3be73d9a0936008b88e99105ab337ad0f66095a65eb4f7408fe8587ac91a/docpress-1.4.18.tar.gz"
  sha256 "ea92ca9665d34a02228525930223f47590c8f128d37be7d20305e13859db25ea"
  license "MIT"

  # Pango's shared libraries. Do not depend on Homebrew's weasyprint formula.
  # Homebrew's dart-sass formula puts the sass command on PATH.
  depends_on "pango"
  depends_on "python@3.12"
  depends_on "dart-sass"

  def install
    # Homebrew's pip_install passes --no-deps. This formula installs the
    # published extras, and pip fetches those extras' dependencies from PyPI.
    virtualenv_create(libexec, "python3.12", system_site_packages: false)
    python3 = Formula["python@3.12"].opt_bin/"python3.12"
    system python3, "-m", "pip", "--python=#{libexec}/bin/python", "install",
           "--disable-pip-version-check", "docpress[pdf,site]==#{version}"

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
