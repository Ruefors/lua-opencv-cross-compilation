function(vcpkg_regex_replace_string filename match replace)
    file(READ "${filename}" old_contents)
    string(REGEX REPLACE "${match}" "${replace}" new_contents "${old_contents}")
    if (NOT "${new_contents}" STREQUAL "${old_contents}")
        file(WRITE "${filename}" "${new_contents}")
    endif()
endfunction()