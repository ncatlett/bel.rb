require 'mkmf'
require 'fileutils'

BUILD_DEPS = {
  ['make', 'gmake'] => "Error: GNU make is required to build bel.rb.",
  ['autoreconf'   ] => "Error: Autotools is required to build bel.rb."
}

RbConfig::MAKEFILE_CONFIG['CC'] = ENV['CC'] if ENV['CC']

$CFLAGS << " #{ENV["CFLAGS"]}"
$CFLAGS << " -g"
$CFLAGS << " -O3" unless $CFLAGS[/-O\d/]
$CFLAGS << " -Wall -Wno-comment"

# check dependencies
BUILD_DEPS.each do |deps, msg|
  unless deps.any? { |dep| find_executable(dep) }
    abort msg
  end
end

# determine make
MAKE = find_executable('gmake') || find_executable('make')

# compute directory paths
CWD        = File.expand_path(File.dirname(__FILE__))
ROOT_DIR   = File.join(CWD, '..', '..')
LIB_DIR    = File.join(ROOT_DIR, 'lib')
LIBBEL_DIR = File.join(ROOT_DIR, 'vendor', 'libbel')

# build libbel using autotools
Dir.chdir(LIBBEL_DIR) do
  system("./autogen.sh")
  system("./configure")
  system("#{MAKE} clean all")
end

LIBBEL_SO = File.join(LIBBEL_DIR, 'src', '.libs', 'libbel.so')
FileUtils.cp(LIBBEL_SO, LIB_DIR)

create_makefile("bel/bel")
