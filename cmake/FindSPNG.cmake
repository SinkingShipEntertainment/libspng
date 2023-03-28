#[=======================================================================[.rst:
FindSPNG
-------

Find libspng, library for the PNG image format.

This module defines the following :prop_tgt:`IMPORTED` target:

``SPNG::SPNG``
  The libspng library, if found.

Result variables
^^^^^^^^^^^^^^^^

This module will set the following variables in your project:

``SPNG_INCLUDE_DIRS``
  where to find png.h, etc.
``SPNG_LIBRARIES``
  the libraries to link against to use PNG.
``PNG_DEFINITIONS``
  You should add_definitions(${PNG_DEFINITIONS}) before compiling code
  that includes png library files.
``PNG_FOUND``
  If false, do not try to use PNG.
``PNG_VERSION_STRING``
  the version of the PNG library found (since CMake 2.8.8)

Obsolete variables
^^^^^^^^^^^^^^^^^^

The following variables may also be set, for backwards compatibility:

``SPNG_LIBRARY``
  where to find the PNG library.
``SPNG_INCLUDE_DIR``
  where to find the PNG headers (same as SPNG_INCLUDE_DIRS)

Since PNG depends on the ZLib compression library, none of the above
will be defined unless ZLib can be found.
#]=======================================================================]

if(SPNG_FIND_QUIETLY)
  set(_FIND_ZLIB_ARG QUIET)
endif()
find_package(ZLIB ${_FIND_ZLIB_ARG})

if(ZLIB_FOUND)
  find_path(SPNG_SPNG_INCLUDE_DIR
    spng.h
    HINTS
      $ENV{REZ_LIBSPNG_ROOT}
    PATH_SUFFIXES
      include
  )
  mark_as_advanced(SPNG_SPNG_INCLUDE_DIR)

    # For compatibility with versions prior to this multi-config search, honor
  # any SPNG_LIBRARY that is already specified and skip the search.
  if(NOT SPNG_LIBRARY)
    find_library(SPNG_LIBRARY
      NAMES
        libspng.so
      HINTS
        $ENV{REZ_LIBSPNG_ROOT}
      PATH_SUFFIXES
        lib
      )

    include(SelectLibraryConfigurations)
    select_library_configurations(SPNG)
    mark_as_advanced(SPNG_LIBRARY)
  endif()

  # Set by select_library_configurations(), but we want the one from
  # find_package_handle_standard_args() below.
  unset(SPNG_FOUND)

  if (SPNG_LIBRARY AND SPNG_SPNG_INCLUDE_DIR)
      set(SPNG_INCLUDE_DIRS ${SPNG_SPNG_INCLUDE_DIR})
      set(SPNG_INCLUDE_DIR ${SPNG_INCLUDE_DIRS} ) # for backward compatibility
      set(SPNG_LIBRARIES ${SPNG_LIBRARY} ${ZLIB_LIBRARY})
      if((CMAKE_SYSTEM_NAME STREQUAL "Linux") AND
         ("${SPNG_LIBRARY}" MATCHES "\\${CMAKE_STATIC_LIBRARY_SUFFIX}$"))
        list(APPEND SPNG_LIBRARIES m)
      endif()

      if (CYGWIN)
        if(BUILD_SHARED_LIBS)
           # No need to define PNG_USE_DLL here, because it's default for Cygwin.
        else()
          set (SPNG_DEFINITIONS -DSPNG_STATIC)
          set(_SPNG_COMPILE_DEFINITIONS SPNG_STATIC)
        endif()
      endif ()

      if(NOT TARGET SPNG::SPNG)
        add_library(SPNG::SPNG UNKNOWN IMPORTED)
        set_target_properties(SPNG::SPNG PROPERTIES
          INTERFACE_COMPILE_DEFINITIONS "${_SPNG_COMPILE_DEFINITIONS}"
          INTERFACE_INCLUDE_DIRECTORIES "${SPNG_INCLUDE_DIRS}"
          INTERFACE_LINK_LIBRARIES ZLIB::ZLIB)
        if((CMAKE_SYSTEM_NAME STREQUAL "Linux") AND
           ("${SPNG_LIBRARY}" MATCHES "\\${CMAKE_STATIC_LIBRARY_SUFFIX}$"))
          set_property(TARGET SPNG::SPNG APPEND PROPERTY
            INTERFACE_LINK_LIBRARIES m)
        endif()

        if(EXISTS "${SPNG_LIBRARY}")
          set_target_properties(SPNG::SPNG PROPERTIES
            IMPORTED_LINK_INTERFACE_LANGUAGES "C"
            IMPORTED_LOCATION "${SPNG_LIBRARY}")
        endif()
      endif()

      unset(_SPNG_COMPILE_DEFINITIONS)
  endif ()

  if (SPNG_SPNG_INCLUDE_DIR AND EXISTS "${SPNG_SPNG_INCLUDE_DIR}/spng.h")
      file(STRINGS "${SPNG_SPNG_INCLUDE_DIR}/spng.h" spng_version_major REGEX "^#define[ \t]+SPNG_VERSION_MAJOR[ \t]+\".+\"")
      string(REGEX REPLACE "^#define[ \t]+SPNG_VERSION_MAJOR[ \t]+\"([^\"]+)\".*" "\\1" SPNG_VERSION_MAJOR "${spng_version_major}")
      unset(spng_version_major)

      file(STRINGS "${SPNG_SPNG_INCLUDE_DIR}/spng.h" spng_version_minor REGEX "^#define[ \t]+SPNG_VERSION_MINOR[ \t]+\".+\"")
      string(REGEX REPLACE "^#define[ \t]+SPNG_VERSION_MINOR[ \t]+\"([^\"]+)\".*" "\\1" SPNG_VERSION_MINOR "${spng_version_minor}")
      unset(spng_version_minor)

      file(STRINGS "${SPNG_SPNG_INCLUDE_DIR}/spng.h" spng_version_patch REGEX "^#define[ \t]+SPNG_VERSION_PATCH[ \t]+\".+\"")
      string(REGEX REPLACE "^#define[ \t]+SPNG_VERSION_PATCH[ \t]+\"([^\"]+)\".*" "\\1" SPNG_VERSION_PATCH "${spng_version_patch}")
      unset(spng_version_patch)

      set(SPNG_VERSION_STRING ${SPNG_VERSION_MAJOR}.${SPNG_VERSION_MINOR}.${SPNG_VERSION_PATCH})
  endif ()
endif()

#include(${CMAKE_CURRENT_LIST_DIR}/FindPackageHandleStandardArgs.cmake)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  SPNG
  REQUIRED_VARS
    SPNG_LIBRARY
    SPNG_SPNG_INCLUDE_DIR
    SPNG_VERSION_STRING
)
