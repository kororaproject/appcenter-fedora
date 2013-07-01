# Check http://webdev.elementaryos.org/docs/developer-guide/cmake for documentation

cmake_minimum_required (VERSION 2.6)
cmake_policy (VERSION 2.6)
project (appcenter)
enable_testing ()
set (LAUNCHER "appcenter.desktop")
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/appcenter")
set (PLUGINSDIR "${PKGDATADIR}/plugins")
set (GETTEXT_PACKAGE "appcenter")
add_definitions(-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")
set (RELEASE_NAME "AppCenter.")
set (PKGNAME "appcenter")
set (LIBNAME "appcentercore")
set (VERSION "0.1")
set (SOVERSION 0)
set (VERSION_INFO "Release")
set (CMAKE_C_FLAGS "-ggdb")
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (DOLLAR "$")
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

# Some configuration
configure_file (${CMAKE_SOURCE_DIR}/src/config.vala.cmake ${CMAKE_SOURCE_DIR}/src/config.vala)

# Vala
find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.18" MINIMUM)
include (ValaPrecompile)

# GSettings
include(GSettings)
add_schema("org.pantheon.appcenter.gschema.xml")

# Deps
set (APPCENTER_DEPS "glib-2.0;gee-1.0;gobject-2.0;gio-2.0;gtk+-3.0;granite;libpeas-1.0;packagekit-glib2;sqlheavy-0.1;appstore;unity;json-glib-1.0")
find_package (PkgConfig)
pkg_check_modules (GLIB REQUIRED "glib-2.0 >= 2.26.0")
pkg_check_modules (GOBJECT REQUIRED "gobject-2.0 >= 2.26.0")
pkg_check_modules (GIO REQUIRED "gio-2.0 >= 2.26.0")
pkg_check_modules (GTK+ REQUIRED "gtk+-3.0 >= 3.4")
pkg_check_modules (LIBGRANITE REQUIRED "granite")
pkg_check_modules (LIBPEASGTK REQUIRED "libpeas-gtk-1.0")
pkg_check_modules (LIBUNITY REQUIRED "unity")
pkg_check_modules (LIBAPPSTORE REQUIRED "appstore")
pkg_check_modules (LIBSQLHEAVY REQUIRED "sqlheavy-0.1 >= 0.1")
pkg_check_modules (GTHREAD REQUIRED "gthread-2.0 >= 2.14.0")
pkg_check_modules (DEPS REQUIRED ${APPCENTER_DEPS} gthread-2.0)

set(NORMAL_CFLAGS ${DEPS_CFLAGS} ${LIBSOURCE_CFLAGS} ${LIBAPPSTORE_CFLAGS})
set(NORMAL_LINK_DIRS ${DEPS_LIBRARY_DIRS} ${LIBSOURCE_LIBRARY_DIRS} ${LIBAPPSTORE_LIBRARY_DIRS})
set(NORMAL_LIBRARIES ${DEPS_LIBRARIES} ${LIBSOURCE_LIBRARIES} ${LIBAPPSTORE_LIBRARIES})

add_definitions (${DEPS_CFLAGS} ${LIBSOURCE_CFLAGS} ${GCONF_CFLAGS})
link_libraries (${DEPS_LIBRARIES} ${LIBSOURCE_LIBRARIES} ${GCONF_LIBRARIES} ${GTHREAD_LIBRARIES})
link_directories (${DEPS_LIBRARY_DIRS} ${LIBSOURCE_LIBRARY_DIRS} ${GCONF_LIBRARY_DIRS})

# Subdirectories
add_subdirectory (src)
add_subdirectory (plugins)
add_subdirectory (po)
add_subdirectory (data)
