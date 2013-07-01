add_definitions (-DI_KNOW_THE_PACKAGEKIT_GLIB2_API_IS_SUBJECT_TO_CHANGE)

add_definitions(${NORMAL_CFLAGS})
include_directories(${CMAKE_BINARY_DIR} ${CMAKE_BINARY_DIR}/src/)
link_directories(${NORMAL_LINK_DIRS}) 

vala_precompile(VALA_C
    info-expander.vala
PACKAGES
    appcentercore
    ${APPCENTER_DEPS}
OPTIONS
    --thread
    --vapidir=${CMAKE_BINARY_DIR}
    --vapidir=${CMAKE_BINARY_DIR}/src/
    --vapidir=${CMAKE_SOURCE_DIR}/vapi/
)

add_library(info-expander MODULE ${VALA_C})
add_dependencies(info-expander appcentercore)

install(TARGETS info-expander DESTINATION ${PLUGINSDIR}/info-expander)
install(FILES info-expander.plugin DESTINATION ${PLUGINSDIR}/info-expander)

install(DIRECTORY desktop DESTINATION ${PLUGINSDIR}/info-expander)
install(DIRECTORY icons DESTINATION ${PLUGINSDIR}/info-expander)
