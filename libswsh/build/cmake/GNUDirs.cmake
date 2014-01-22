SET(prefix "${CMAKE_INSTALL_PREFIX}" CACHE STRING "Installation prefix")
SET(exec_prefix "\${prefix}" CACHE STRING "Installation prefix for executable files")
SET(libdir "\${prefix}/lib" CACHE STRING "Library installation directory")

IF("${prefix}" STREQUAL "/usr")
  SET(sysconfdir "/etc" CACHE STRING "System configuration directory")
  SET(localstatedir "/var" CACHE STRING "Machine dependant data directory")
ELSE("${prefix}" STREQUAL "/usr")
  SET(sysconfdir "\${prefix}/etc" CACHE STRING "System configuration directory")
  SET(localstatedir "\${prefix}/var" CACHE STRING "Machine dependant data directory")
ENDIF("${prefix}" STREQUAL "/usr")