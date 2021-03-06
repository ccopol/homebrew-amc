# Vendor Pango because of a 'bug' unidentified.
# https://github.com/maelvls/homebrew-amc/issues/33
# https://project.auto-multiple-choice.net/boards/4/topics/8855?r=8904#message-8904
class AmcPango < Formula
  desc "(vendored) Framework for layout and rendering of i18n text"
  homepage "https://www.pango.org/"
  url "https://download.gnome.org/sources/pango/1.42/pango-1.42.4.tar.xz"
  sha256 "1d2b74cd63e8bd41961f2f8d952355aa0f9be6002b52c8aa7699d9f5da597c9d"
  revision 0

  bottle do
    root_url "https://dl.bintray.com/maelvls/bottles-amc"
    rebuild 1
    sha256 "d8bd8e27588e0403f248edab1dc2a866c1e96aa1650dd26357e8ded3dd8f855c" => :catalina
    sha256 "d8bd8e27588e0403f248edab1dc2a866c1e96aa1650dd26357e8ded3dd8f855c" => :mojave
    sha256 "147c6f9eedd3c49afdbe18551d68102f61ec20c9701b4ee28ccb434764a9d221" => :high_sierra
  end

  head do
    url "https://gitlab.gnome.org/GNOME/pango.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "gtk-doc" => :build
    depends_on "libtool" => :build
  end

  depends_on "gobject-introspection" => :build
  depends_on "pkg-config" => :build
  depends_on "cairo"
  depends_on "fontconfig"
  depends_on "fribidi"
  depends_on "glib"
  depends_on "harfbuzz"

  keg_only "Vendored version of Homebrew's pango"

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-html-dir=#{share}/doc",
                          "--enable-introspection=yes",
                          "--enable-static",
                          "--without-xft"

    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/pango-view", "--version"
    (testpath/"test.c").write <<~EOS
      #include <pango/pangocairo.h>

      int main(int argc, char *argv[]) {
        PangoFontMap *fontmap;
        int n_families;
        PangoFontFamily **families;
        fontmap = pango_cairo_font_map_get_default();
        pango_font_map_list_families (fontmap, &families, &n_families);
        g_free(families);
        return 0;
      }
    EOS
    cairo = Formula["cairo"]
    fontconfig = Formula["fontconfig"]
    freetype = Formula["freetype"]
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    libpng = Formula["libpng"]
    pixman = Formula["pixman"]
    flags = %W[
      -I#{cairo.opt_include}/cairo
      -I#{fontconfig.opt_include}
      -I#{freetype.opt_include}/freetype2
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/pango-1.0
      -I#{libpng.opt_include}/libpng16
      -I#{pixman.opt_include}/pixman-1
      -D_REENTRANT
      -L#{cairo.opt_lib}
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{lib}
      -lcairo
      -lglib-2.0
      -lgobject-2.0
      -lintl
      -lpango-1.0
      -lpangocairo-1.0
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
