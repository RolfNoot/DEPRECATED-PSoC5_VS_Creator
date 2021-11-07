cmake_minimum_required(VERSION 3.7.2)

set(DEBUG_ON true)
######################################################################
#
#	Toolchain Setup
#
######################################################################

macro(FIND_DIRECTORIES return_list dir_in)
    FILE(GLOB_RECURSE new_list ${dir_in})
    SET(dir_list "")
    FOREACH(file_path ${new_list})
        GET_FILENAME_COMPONENT(dir_path ${file_path} PATH)
        SET(dir_list ${dir_list} ${dir_path})
    ENDFOREACH()
    LIST(REMOVE_DUPLICATES dir_list)
    SET(${return_list} ${dir_list})
endmacro()

if(${DEBUG_ON})
    set(CMAKE_VERBOSE_MAKEFILE ON CACHE BOOL "ON")
    message("INFO: path=$ENV{PATH}")
endif()

set(TOOLS_DIR $ENV{ONETHINX_PACK_LOC}/tools_2.0)
set(SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/source)
set(CONFIG_DIR ${CMAKE_CURRENT_SOURCE_DIR}/config)
set(CREATOR_DIR ${CMAKE_CURRENT_SOURCE_DIR}/PSoC_Creator.cydsn)
set(CREATOR_SOURCE_DIR ${CREATOR_DIR}/Generated_Source/PSoC5)

if (${CMAKE_HOST_SYSTEM_NAME} MATCHES "Windows")
    find_program (BASH_TOOL ${TOOLS_DIR}/bash/bash.exe DOC "The bash executable")
else()
    find_program (BASH_TOOL bash DOC "The bash executable")
endif()

find_program(CYPRESS_ELF_TOOL CyMcuElfTool "${TOOLS_DIR}/cymcuelftool-1.0/bin" DOC "Cypress ELF tool executable")
find_program(READELF_TOOL arm-none-eabi-readelf "${COMPILER_DIR}" DOC "ReadELF tool executable")

#Get the top directory name. This will be used as project_name in later section
string(FIND ${CMAKE_CURRENT_SOURCE_DIR} / POSITION REVERSE )
MATH(EXPR POSITION "${POSITION}+1")
string(SUBSTRING ${CMAKE_CURRENT_SOURCE_DIR} ${POSITION} -1 TOP_DIR_NAME)
set(ENV{TOP_DIR_NAME} ${TOP_DIR_NAME})

if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/local.cmake)
    include (${CMAKE_CURRENT_SOURCE_DIR}/local.cmake)
endif()

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR ARM)

# Without that flag CMake is not able to pass test compilation check
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

######################################################################
#
#	Project
#
######################################################################

message("INFO: Project \"${TOP_DIR_NAME}\"")
project(${TOP_DIR_NAME})
enable_language(ASM)

#Check if the correct compiler is installed
execute_process(COMMAND ${CMAKE_C_COMPILER} -print-multi-lib OUTPUT_VARIABLE GCC_VERSION)
string(FIND "${GCC_VERSION}" "armv7-m" ARM_V7M_DETECTED)
if (${ARM_V7M_DETECTED} EQUAL "-1")
    message( FATAL_ERROR "Wrong compiler selected, CMake will exit." )
endif()

#Include common settings
include(${CONFIG_DIR}/common.cmake)

######################################################################
#
#	Project compiler & linker options
#
######################################################################

set(PROJECT_FLAGS_ARCH
    "-mthumb"
    "-mcpu=cortex-m3"
    "-DCY_CORE_ID=0"
    "-Wall"
    "-Wtype-limits"
    "-Wunused"
    "-Wunused-parameter"
    "-ffunction-sections"
    "-ffat-lto-objects"
    "-Og"
)
#-g -D DEBUG -D CY_CORE_ID=0 -Wall -ffunction-sections -ffat-lto-objects -Og -c
set(PROJECT_LINKER_FLAGS
    "-Wl,-Map=${PROJECT_NAME}.map"
    "-L${CREATOR_SOURCE_DIR}"
    "-Tcm3gcc.ld"
    "-mcpu=cortex-m3"
    "-mthumb"
    "-specs=nano.specs"
    "-Wl,--gc-sections"
    "-g"
    "-ffunction-sections"
    "-Og"
    "-ffat-lto-objects"
)

######################################################################
#
#	Sources
#
######################################################################

# include these paths
FIND_DIRECTORIES(SOURCE_INCLUDE_DIRS ${SOURCE_DIR}/*.h)
include_directories (
    ${SOURCE_INCLUDE_DIRS}
    ${CREATOR_SOURCE_DIR}
)

# Find Source files (containing *.c)
#FILE(GLOB SOURCE_SRCS ${SOURCE_DIR}/*.c)
FILE(GLOB_RECURSE SOURCE_SRCS ${SOURCE_DIR}/*.c)


set(PROJECT_SRCS
    ${SOURCE_SRCS}
    ${CREATOR_SOURCE_DIR}/CyBootAsmGnu.s
    ${CREATOR_SOURCE_DIR}/cyfitter_cfg.c
    #${CREATOR_SOURCE_DIR}/cymetadata.c
    ${CREATOR_SOURCE_DIR}/Cm3Start.c
)

if(${DEBUG_ON})
    message("INFO: Project sources        = ${PROJECT_SRCS}")
    message("INFO: Project source folder  = ${PROJECT_SOURCE_DIR}")
    message("INFO: Source include folders = ${SOURCE_INCLUDE_DIRS}")
    message("INFO: Source folders         = ${SOURCE_SRCS}")
    message("INFO: Design source folders  = ${DESIGN_SRCS}")
endif()

######################################################################
#
#	TARGET
#
######################################################################
#TODO: Evaluate ASM FLAGS
set (CMAKE_ASM_FLAGS "${C_FLAGS} ${C_FLAGS_WARNINGS} ${FLAGS_OPTIMIZATION} ${PROJECT_FLAGS_ARCH}")
#set (CMAKE_C_FLAGS "${C_FLAGS} ${C_FLAGS_WARNINGS} ${FLAGS_OPTIMIZATION} ${PROJECT_FLAGS_ARCH}")
set (CMAKE_C_FLAGS "${PROJECT_FLAGS_ARCH}")
#set (CMAKE_CXX_FLAGS "${CXX_FLAGS} ${CXX_FLAGS_WARNINGS} ${FLAGS_OPTIMIZATION} ${PROJECT_FLAGS_ARCH}")
set (CMAKE_EXE_LINKER_FLAGS "${PROJECT_LINKER_FLAGS}")

# CMake lists are separated by semicolons, remove these
string(REGEX REPLACE ";" " " CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS}")
string(REGEX REPLACE ";" " " CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
#string(REGEX REPLACE ";" " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
string(REGEX REPLACE ";" " " CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")

#set (CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS}")
#set (CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS}")
#set (CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS}")

#set (CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS}" CACHE STRING "" FORCE)
#set (CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS}" CACHE STRING "" FORCE)
#set (CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS}" CACHE STRING "" FORCE)
#set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}" CACHE STRING "" FORCE)
#set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}" CACHE STRING "" FORCE)

if(${DEBUG_ON})
    message("INFO: ASM Options    = ${CMAKE_ASM_FLAGS}")
    message("INFO: C Options      = ${CMAKE_C_FLAGS}")
    message("INFO: C++ Options    = ${CMAKE_CXX_FLAGS}")
    message("INFO: Linker Options = ${CMAKE_EXE_LINKER_FLAGS}")
endif()

add_executable(${PROJECT_NAME}.elf ${PROJECT_SRCS})

######################################################################
#
#	LIBRARIES  Adding the CyComponent libraries
#
######################################################################
add_library(cycomponentlib STATIC IMPORTED)
add_library(designlib STATIC IMPORTED)

SET_TARGET_PROPERTIES(cycomponentlib PROPERTIES IMPORTED_LOCATION "${CREATOR_DIR}/CyComponentLibrary.a")
TARGET_LINK_LIBRARIES(${PROJECT_NAME}.elf cycomponentlib)

SET_TARGET_PROPERTIES(designlib PROPERTIES IMPORTED_LOCATION "${CREATOR_DIR}/CortexM3/ARM_GCC_541/Debug/PSoC_Creator.a")
TARGET_LINK_LIBRARIES(${PROJECT_NAME}.elf designlib)

######################################################################
#
#	Build actions
#
######################################################################

add_custom_target(
    ${PROJECT_NAME} ALL
    #POST BUILD
    COMMAND ${CONFIG_DIR}/cyelftool -C "${PROJECT_NAME}.elf" --flash_row_size 256 --flash_size 262144 --flash_offset 0x00000000
    COMMAND "${READELF_TOOL}" -Sl ${PROJECT_NAME}.elf > ${PROJECT_NAME}.readelf
    COMMAND "${BASH_TOOL}" ${CONFIG_DIR}/memcalc.bash ${PROJECT_NAME}.readelf "262144" "65536" "0" "536838144" #Flash 0x40000   SRAM 0x10000   Flash start 0x00000000   SRAM start 0x1FFF8000
    DEPENDS "${PROJECT_NAME}.elf"
)
