add_definitions (-DI_KNOW_THE_PACKAGEKIT_GLIB2_API_IS_SUBJECT_TO_CHANGE)

vala_precompile(VALA_C
    AppCenter.vala
    MainWindow.vala
    Utils.vala
    config.vala
    Services/PluginsManager.vala
    Services/Settings.vala
    Services/Screenshots.vala
    Services/Unity.vala
    Widgets/Boxes.vala
    Widgets/Buttons.vala
    Widgets/EmbeddedAlert.vala
    Widgets/GridView.vala
    Widgets/PagesView.vala
    Widgets/ProgressInfo.vala
    Widgets/Toolbar.vala
    Widgets/Pages/AppsInfo.vala
    Widgets/Pages/AppsView.vala
    Widgets/Pages/CategoriesView.vala
    Widgets/Pages/ErrorPage.vala
    Widgets/Pages/HomePage.vala
    Widgets/Pages/UpdatesView.vala
PACKAGES
    ${APPCENTER_DEPS}
OPTIONS
    --vapidir=${CMAKE_SOURCE_DIR}/vapi
    --thread
GENERATE_VAPI
    ${LIBNAME}
GENERATE_HEADER
    ${LIBNAME}
)
# tranlation stuff

add_executable (appcenter ${VALA_C})

install (TARGETS appcenter RUNTIME DESTINATION bin)

# Bild library for plugins
add_library (${LIBNAME} SHARED
    ${VALA_C}
)

if(BUILD_STATIC MATCHES "Yes")
add_library (${LIBNAME}-static STATIC ${VALA_C})
set_target_properties (${PKGNAME}-static PROPERTIES OUTPUT_NAME ${LIBNAME})
install (TARGETS ${LIBNAME}-static DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/)
endif(BUILD_STATIC MATCHES "Yes")

set_target_properties (${LIBNAME} PROPERTIES
    VERSION ${LIBNAME}
    SOVERSION ${SOVERSION}
                       )
# Install lib stuffs
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/${LIBNAME}.pc.cmake ${CMAKE_CURRENT_BINARY_DIR}/${LIBNAME}.pc)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${LIBNAME}.pc DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/pkgconfig/)
install (TARGETS ${LIBNAME} DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${LIBNAME}.vapi DESTINATION ${CMAKE_INSTALL_PREFIX}/share/vala/vapi/)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/${LIBNAME}.h DESTINATION ${CMAKE_INSTALL_PREFIX}/include/${LIBNAME}/)

target_link_libraries(appcenter ${NORMAL_LIBRARIES})
