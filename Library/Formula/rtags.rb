class Rtags < Formula
  def llvm_version
    build.head? ? "3.6" : "3.5"
  end

  def llvm
    "llvm" + (build.head? ? (llvm_version.delete ".") : "")
  end

  def llvm_bin
    f = Formulary.factory llvm
    if f.rack.directory?
      kegs = f.rack.subdirs.map { |keg| Keg.new(keg) }.sort_by(&:version)
      Pathname.new("#{kegs.last}") + "bin"
    end
  end

  def llvm_config
    llvm_bin + ("llvm-config-" + llvm_version)
  end

  def clang
    llvm_bin + ("clang-" + llvm_version)
  end

  def clangxx
    llvm_bin + ("clang++-" + llvm_version)
  end

  homepage "https://github.com/Andersbakken/rtags"

  stable do
    url "https://github.com/Andersbakken/rtags/archive/v2.0.tar.gz"
    sha256 "36733945ea34517903a0e5b800b06a41687ee25d3ab360072568523e5d610d6f"

    resource "rct" do
      url "https://github.com/Andersbakken/rct.git", :revision => "10700c615179f07d4832d459e6453eed736cfaef"
    end

    depends_on "llvm" => ["with-clang", "without-assertions", "with-rtti"]
  end

  head do
    url "https://github.com/Andersbakken/rtags.git"

    depends_on "homebrew/versions/llvm36" => "without-assertions"
  end

  depends_on "cmake" => :build

  def install
    unless build.head?
      (buildpath/"src/rct").install resource("rct")
    end

    mkdir "build" do
      args = std_cmake_args
      args << "-DLLVM_CONFIG=" + llvm_config
      args << "-DCMAKE_C_COMPILER=" + clang
      args << "-DCMAKE_CXX_COMPILER=" + clangxx
      args << ".."

      system "cmake", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    system "sh", "-c", "rc >/dev/null --help  ; test $? == 1"
  end
end
