######################################################################
#
#	Warnings
#
######################################################################

set(C_FLAGS_WARNINGS
    "-Wall"
    "-Wno-unused-function"
    #"-Werror-implicit-function-declaration"
    #"-Wfloat-equal"
    #"-Wno-type-limits"
    #"-Wno-unused-parameter"
    #"-Wno-expansion-to-defined"
    #"-Wno-implicit-fallthrough"
    #"-Wpointer-arith"
    #"-Wunreachable-code" 
    #"-Wwrite-strings"
)

set(C_FLAGS_WARNINGS_EXTRA
    "-Wextra"
    "-Waggregate-return"
    "-Wattributes"
    "-Wbad-function-cast"
    "-Wcast-align"
    "-Wlong-long"
    "-Wmissing-declarations"
    "-Wmissing-format-attribute"
    "-Wmissing-prototypes"
    "-Wnested-externs"
    "-Wpacked"
    "-Wredundant-decls"
    "-Wshadow"
    "-Wstrict-prototypes"
    "-Wundef"
    "-Wunused"
)

######################################################################
#
#	Compiler options except warnings
#
######################################################################

message("${CMAKE_BUILD_TYPE}")
IF(${CMAKE_BUILD_TYPE} MATCHES [dD][eE][bB][uU][gG])
  message("Debug build.")
    set(FLAGS_OPTIMIZATION
        "-DDEBUG"
        "-ffunction-sections"
        "-ffat-lto-objects"
        "-Og"
        "-fno-exceptions"
        "-fmessage-length=0"
        "-fsigned-char"
        "-fdata-sections"
        "-g3"
    )
ELSEIF(${CMAKE_BUILD_TYPE} MATCHES [rR][eE][lL][wW][iI][tT][hH][dD][eE][bB][iI][nN][fF][oO])
  message("Release build with debug info.")
    set(FLAGS_OPTIMIZATION
        "-DDEBUG"
        "-ffunction-sections"
        "-ffat-lto-objects"
        "-Os"
        "-fno-exceptions"
        "-fmessage-length=0"
        "-fsigned-char"
        "-fdata-sections"
        "-g2"
    )
ELSE()
    message("Release build.")
    set(FLAGS_OPTIMIZATION
        "-DNDEBUG"
        "-ffunction-sections"
        "-ffat-lto-objects"
        "-Os"
        "-fno-exceptions"
        "-fmessage-length=0"
        "-fsigned-char"
        "-fdata-sections"
        "-g"
    )
ENDIF()

set(C_FLAGS "")

set(CXX_FLAGS "-std=gnu++11 -fdevirtualize-speculatively -fno-rtti")

######################################################################
#
#	Linker
#
######################################################################

set(LINKER_FLAGS
    "--specs=nosys.specs"
    "-L${LINKER_DIR}"
    "-Wl,--gc-sections"
    "-ffunction-sections"
    "-ffat-lto-objects"
)