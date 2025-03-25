# The directory that contains `stdlib.h`.
# On POSIX-like systems, include directories be found with: `cc -E -Wp,-v -xc /dev/null`
include_dir=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.2.sdk/usr/include

# The system-specific include directory. May be the same as `include_dir`.
# On Windows it's the directory that includes `vcruntime.h`.
# On POSIX it's the directory that includes `sys/errno.h`.
sys_include_dir=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX15.2.sdk/usr/include

# The directory that contains `crt1.o` or `crt2.o`.
# On POSIX, can be found with `cc -print-file-name=crt1.o`.
# Not needed when targeting MacOS.
crt_dir=

# The directory that contains `vcruntime.lib`.
# Only needed when targeting MSVC on Windows.
msvc_lib_dir=

# The directory that contains `kernel32.lib`.
# Only needed when targeting MSVC on Windows.
kernel32_lib_dir=

# The directory that contains `crtbeginS.o` and `crtendS.o`
# Only needed when targeting Haiku.
gcc_dir=
