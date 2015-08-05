#
# Application
#
add_executable(vplayer
    main.cpp
)

target_link_libraries(vplayer
    Qt5::Quick
    Qt5::Widgets
    Qt5::Qml
    KF5::ConfigCore
    KF5::DBusAddons
    KF5::I18n
)

install(TARGETS vplayer ${INSTALL_TARGETS_DEFAULT_ARGS})

install (FILES org.kde.mobile.vplayer.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
