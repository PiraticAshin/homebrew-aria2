class Aria2 < Formula
  desc "Download with resuming and segmented downloading"
  homepage "https://aria2.github.io/"
  url "https://github.com/aria2/aria2/releases/download/release-1.36.0/aria2-1.36.0.tar.xz"
  version "1.36.0-piercec"
  sha256 "58d1e7608c12404f0229a3d9a4953d0d00c18040504498b483305bcb3de907a5"
  license "GPL-2.0-or-later"

  option "with-c-ares", "Enable c-ares support"
  option "with-openssl", "Use OpenSSL instead of Apple TLS" if OS.mac?

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "libssh2"
  depends_on "sqlite"

  depends_on "c-ares" => :optional

  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  on_linux do
    depends_on "openssl@1.1"
  end

  on_macos do
    depends_on "openssl@1.1" => :optional
  end

  def install
    ENV.cxx11

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --with-libssh2
      --without-gnutls
      --without-libgmp
      --without-libnettle
      --without-libgcrypt
    ]
    
    if OS.mac?
      if build.with? "openssl@1.1"
        ENV.prepend_path "PKG_CONFIG_PATH", Formula["openssl@1.1"].opt_lib/"pkgconfig"
        args << "--without-appletls"
        args << "--with-openssl"
      else
        args << "--with-appletls"
        args << "--without-openssl"
      end
    else
      args << "--without-appletls"
      args << "--with-openssl"
    end

    args << "--with-libcares" if build.with?("c-ares")

    system "./configure", *args
    system "make", "install"

    bash_completion.install "doc/bash_completion/aria2c"
  end

  test do
    system "#{bin}/aria2c", "https://brew.sh/"
    assert_predicate testpath/"index.html", :exist?, "Failed to create index.html!"
  end
end
