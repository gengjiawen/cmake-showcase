cmake_minimum_required(VERSION 3.20)

function(useCompilerCache)
  if(NOT CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    return()
  endif()

  find_program(CCACHE_EXECUTABLE ccache)
  if(NOT CCACHE_EXECUTABLE)
    return()
  endif()

  if(MSVC)
    # Disable use of separate PDB, Ccache won't cache
    # things otherwise
    foreach(lang IN ITEMS C CXX)
      foreach(config IN LISTS
              CMAKE_BUILD_TYPE CMAKE_CONFIGURATION_TYPES)
        set(var CMAKE_${lang}_FLAGS)
        if(NOT config STREQUAL "")
          string(TOUPPER "${config}" config)
          string(APPEND var "_${config}")
        endif()
        string(REPLACE "/Zi" "/Z7" ${var} "${${var}}")
        string(REPLACE "/ZI" "/Z7" ${var} "${${var}}")
        set(${var} "${${var}}" PARENT_SCOPE)
      endforeach()
    endforeach()
  endif()

  # Use a cache variable so the user can override this
  set(CCACHE_ENV
    CCACHE_SLOPPINESS=pch_defines,time_macros
    CACHE STRING
    "List of environment variables for ccache, each in key=value form"
  )

  if(CMAKE_GENERATOR MATCHES "Ninja|Makefiles")
    foreach(lang IN ITEMS C CXX OBJC OBJCXX CUDA)
      set(CMAKE_${lang}_COMPILER_LAUNCHER
        ${CMAKE_COMMAND} -E env
        ${CCACHE_ENV} ${CCACHE_EXECUTABLE}
        PARENT_SCOPE
      )
    endforeach()
  elseif(CMAKE_GENERATOR STREQUAL Xcode)
    foreach(lang IN ITEMS C CXX)
      list(JOIN CCACHE_ENV "\nexport " setEnv)
      if(NOT setEnv STREQUAL "")
        string(PREPEND setEnv "export ")
      endif()
      set(launch${lang} ${CMAKE_BINARY_DIR}/launch-${lang})
      file(WRITE ${launch${lang}}
        "#!/bin/bash\n"
        "${setEnv}\n"
        "exec \"${CCACHE_EXECUTABLE}\" "
        "\"${CMAKE_${lang}_COMPILER}\" \"$@\"\n"
      )
      execute_process(COMMAND chmod a+rx ${launch${lang}})
    endforeach()
    set(CMAKE_XCODE_ATTRIBUTE_CC ${launchC}
        PARENT_SCOPE)
    set(CMAKE_XCODE_ATTRIBUTE_CXX ${launchCXX}
        PARENT_SCOPE)
    set(CMAKE_XCODE_ATTRIBUTE_LD ${launchC}
        PARENT_SCOPE)
    set(CMAKE_XCODE_ATTRIBUTE_LDPLUSPLUS ${launchCXX}
        PARENT_SCOPE)

  elseif(CMAKE_GENERATOR MATCHES "Visual Studio")
    cmake_path(NATIVE_PATH CCACHE_EXECUTABLE ccacheExe)
    list(JOIN CCACHE_ENV "\nset " setEnv)
    if(NOT setEnv STREQUAL "")
      string(PREPEND setEnv "set ")
    endif()
    file(WRITE ${CMAKE_BINARY_DIR}/launch-cl.cmd
      "@echo off\n"
      "${setEnv}\n"
      "\"${ccacheExe}\" \"${CMAKE_C_COMPILER}\" %*\n"
    )
    list(FILTER CMAKE_VS_GLOBALS EXCLUDE
      REGEX "^(CLTool(Path|Exe)|TrackFileAccess)=.*$"
    )
    list(APPEND CMAKE_VS_GLOBALS
      CLToolPath=${CMAKE_BINARY_DIR}
      CLToolExe=launch-cl.cmd
      TrackFileAccess=false
    )
    if(NOT CMAKE_VS_GLOBALS MATCHES "(^|;)UseMultiToolTask=")
      list(APPEND CMAKE_VS_GLOBALS UseMultiToolTask=true)
    endif()
    if(NOT CMAKE_VS_GLOBALS MATCHES
       "(^|;)EnforceProcessCountAcrossBuilds=")
      list(APPEND CMAKE_VS_GLOBALS
        EnforceProcessCountAcrossBuilds=true
      )
    endif()
    set(CMAKE_VS_GLOBALS "${CMAKE_VS_GLOBALS}" PARENT_SCOPE)

  endif()
endfunction()