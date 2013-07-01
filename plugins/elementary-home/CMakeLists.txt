add_definitions (-DI_KNOW_THE_PACKAGEKIT_GLIB2_API_IS_SUBJECT_TO_CHANGE)

add_definitions(${NORMAL_CFLAGS})
include_directories(${CMAKE_BINARY_DIR} ${CMAKE_BINARY_DIR}/src/)
link_directories(${NORMAL_LINK_DIRS})

vala_precompile(VALA_C
    elementary-home.vala
PACKAGES
    appcentercore
    ${APPCENTER_DEPS}
OPTIONS
    --thread
    --vapidir=${CMAKE_BINARY_DIR}
    --vapidir=${CMAKE_BINARY_DIR}/src/
    --vapidir=${CMAKE_SOURCE_DIR}/vapi/
)

add_library(elementary-home MODULE ${VALA_C})
add_dependencies(elementary-home appcentercore)

install(TARGETS elementary-home DESTINATION ${PLUGINSDIR}/elementary-home)
install(FILES elementary-home.plugin DESTINATION ${PLUGINSDIR}/elementary-home)

install(DIRECTORY desktop DESTINATION ${PLUGINSDIR}/elementary-home)
install(DIRECTORY icons DESTINATION ${PLUGINSDIR}/elementary-home)
