project(VPlayer)
cmake_minimum_required(VERSION 2.8.12)

# Find extra-cmake-modules
find_package(ECM 0.0.9 REQUIRED NO_MODULE)

# where to look first for cmake modules, before ${CMAKE_ROOT}/Modules/ is checked
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR})

# Find packages
find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Qml Quick Widgets Test Sql)
find_package(KF5 5.5 REQUIRED COMPONENTS Plasma I18n Declarative Config DBusAddons)
find_package(KF5Kirigami REQUIRED)

include(FeatureSummary)
include(ECMAddTests)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings)
include(GenerateExportHeader)
include(ECMInstallIcons)

include_directories(
  ${CMAKE_SOURCE_DIR}
  ${CMAKE_SOURCE_DIR}/src
  ${CMAKE_BINARY_DIR}/src
)

kde_enable_exceptions()

add_subdirectory(src)
add_subdirectory(qml)
add_subdirectory(icons)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
