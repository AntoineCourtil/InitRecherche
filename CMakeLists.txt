cmake_minimum_required(VERSION 3.9)
project(InitRecherche)

add_custom_target(InitRecherche ALL
        COMMAND /usr/bin/swift build
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        SOURCES Sources/main.swift)
