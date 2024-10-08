set(TARGET_NAME InHouse_TheKullayContyApproximation)
include_directories("${CMAKE_CURRENT_SOURCE_DIR}/../" "${STB_ROOT}" "${ASSIMP_ROOT}/include")

add_executable(${TARGET_NAME}
        main.cpp
        GLWidget.cpp
        "${CMAKE_CURRENT_SOURCE_DIR}/../Helper/CubeGeometry.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/../Helper/SkyboxGeometry.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/../Helper/SphereGeometry.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/../Helper/RectangleGeometry.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/../Helper/CustomGeometry.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/../Helper/Geometry.cpp"
        "${CMAKE_CURRENT_SOURCE_DIR}/../Helper/Camera.cpp")

add_executable(EavgImage
        Eavg.cpp)

target_link_libraries(${TARGET_NAME} Qt6::Core)
target_link_libraries(${TARGET_NAME} Qt6::Widgets)
target_link_libraries(${TARGET_NAME} Qt6::Gui)
if(${ASSIMP_ROOT})
    target_link_libraries(${TARGET_NAME} ${ASSIMP_ROOT}/lib/assimp-vc141-mt.lib)
else()
    target_link_libraries(${TARGET_NAME} assimp::assimp)
endif()

set(INSTALL_DIR "${CMAKE_SOURCE_DIR}/bin")
install (TARGETS ${TARGET_NAME} DESTINATION ${INSTALL_DIR})
install (TARGETS EavgImage DESTINATION ${INSTALL_DIR})