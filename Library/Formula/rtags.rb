class Rtags < Formula
  def llvm_version;  '3.6'                                                                     end
  def llvm;          'llvm' + (llvm_version.delete  '.')                                       end
  def llvm_bin;      Pathname.new("#{HOMEBREW_CELLAR}") + llvm + (llvm_version + '.0') + 'bin' end
  def llvm_config;   llvm_bin + ('llvm-config-' + llvm_version)                                end
  def clang;         llvm_bin + ('clang-' + llvm_version)                                      end
  def clangxx;       llvm_bin + ('clang++-' + llvm_version)                                    end

  homepage "https://github.com/Andersbakken/rtags"

  stable do
    url "https://github.com/Andersbakken/rtags/archive/v2.0.tar.gz"
    version "2.0"
    sha256 "36733945ea34517903a0e5b800b06a41687ee25d3ab360072568523e5d610d6f"

    resource "rct" do
      url "https://github.com/Andersbakken/rct.git", :revision => "10700c615179f07d4832d459e6453eed736cfaef"
    end
  end

  head "https://github.com/Andersbakken/rtags.git"

  depends_on "cmake" => :build
  #depends_on lvm => %w{with-libcxx with-clang without-assertions rtti}

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
