cmake_minimum_required(VERSION 3.10)
project(InitRecherche)

add_custom_target(InitRecherche
        COMMAND /home/xnr/.swiftenv/versions/4.1.1-RELEASE/usr/bin/swift build
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        SOURCES Sources/InitRecherche/Coordinate.swift Sources/InitRecherche/Maillage.swift Sources/InitRecherche/main.swift Tests/InitRechercheTests/InitRechercheTests.swift Tests/LinuxMain.swift Package.swift)

