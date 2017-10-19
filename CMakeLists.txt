cmake_minimum_required(VERSION 3.5)

# Definitions
set(PROJECT_NAME cense_coder)

#project(cense_coder)
project(${PROJECT_NAME})

include_directories (./ "${PROJECT_SOURCE_DIR}/embedded/stm")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99")

set(SOURCE_FILES embedded/stm/audio_analyzer/acoustic_indicators.c
   )

add_library(cense_coder ${SOURCE_FILES})


#------------#
#    TEST 1
#------------#

# Data files
set(TEST_DATA_DIR "${PROJECT_BINARY_DIR}/Testing")
file(COPY embedded/stm/tests/speak_32000Hz_16bitsPCM_10s.raw embedded/stm/tests/speak_44100Hz_16bitsPCM_10s.raw
    DESTINATION ${TEST_DATA_DIR})

# Test executable and folder
set(CENSE_CODER_TESTS
    embedded/stm/tests/test_acoustic_indicators.c)


add_executable(TEST_cense_coder ${CENSE_CODER_TESTS})


target_link_libraries (TEST_cense_coder
cense_coder m)


set_property(TARGET TEST_cense_coder PROPERTY FOLDER "tests")


# Add to test suite
enable_testing()
add_test( NAME cense_coder
    WORKING_DIRECTORY ${TEST_DATA_DIR}
    COMMAND TEST_cense_coder )
