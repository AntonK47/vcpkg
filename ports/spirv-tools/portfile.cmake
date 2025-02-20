vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/SPIRV-Tools
    REF "vulkan-sdk-${VERSION}"
    SHA512 c393609b81e74dcf5d9889c2b34599611965353884aa474c11f8a2a815d3eac00f5b34c3a78aba9983b96cae651c6bd313654048100a4be3a35ccaf56a6cdc2d
    PATCHES
        cmake-config-dir.diff
        spirv-tools-shared.diff
        fix-tool-deps.diff
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        tools   SPIRV_SKIP_EXECUTABLES
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DSPIRV-Headers_SOURCE_DIR=${CURRENT_INSTALLED_DIR}"
        -DSPIRV_SKIP_TESTS=ON
        -DSPIRV_TOOLS_BUILD_STATIC=ON
        -DSPIRV_WERROR=OFF
    OPTIONS_DEBUG
        -DSPIRV_SKIP_EXECUTABLES=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPIRV-Tools PACKAGE_NAME spirv-tools DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPIRV-Tools-link PACKAGE_NAME spirv-tools-link DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPIRV-Tools-lint PACKAGE_NAME spirv-tools-lint DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPIRV-Tools-opt PACKAGE_NAME spirv-tools-opt DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SPIRV-Tools-reduce PACKAGE_NAME spirv-tools-reduce) # now delete
vcpkg_fixup_pkgconfig()

if("tools" IN_LIST FEATURES)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/spirv-lesspipe.sh" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/spirv-lesspipe.sh")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/spirv-lesspipe.sh")
    set(tools spirv-as spirv-cfg spirv-dis spirv-link spirv-lint spirv-opt spirv-val)
    if(NOT VCPKG_TARGET_IS_IOS)
        list(APPEND tools spirv-reduce)
    endif()
    vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)
endif()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
