cmake_minimum_required(VERSION 3.5)

# Definitions
set(PROJECT_NAME cense_coder)

#project(cense_coder)
project(${PROJECT_NAME})

include_directories (./ "${PROJECT_SOURCE_DIR}/embedded/stm")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99")

set(SOURCE_FILES embedded/stm/audio_analyzer/acoustic_indicators.c
                 embedded/stm/tests/test_acoustic_indicators.c
   )

add_executable(cense_coder ${SOURCE_FILES})
