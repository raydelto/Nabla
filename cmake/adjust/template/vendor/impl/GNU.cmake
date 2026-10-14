include("${CMAKE_CURRENT_LIST_DIR}/reset.cmake")

# vendor template with options fitting for both C and CXX LANGs

if(NOT DEFINED LANG)
	message(FATAL_ERROR "LANG must be defined!")
endif()

# NOTE: unlike the Clang profile there is no crash-diagnostics block, GCC has no equivalent

NBL_REQUEST_COMPILE_OPTION_SUPPORT(LANG ${LANG} COMPILE_OPTIONS
	################
	# TODO: (****) ->
	-mbmi # https://gcc.gnu.org/onlinedocs/gcc/x86-Options.html
	-mlzcnt # https://gcc.gnu.org/onlinedocs/gcc/x86-Options.html
	-mpclmul # https://gcc.gnu.org/onlinedocs/gcc/x86-Options.html
	################ <-

	-Wextra # https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html
	-maes # https://gcc.gnu.org/onlinedocs/gcc/x86-Options.html
	-mfpmath=sse # https://gcc.gnu.org/onlinedocs/gcc/x86-Options.html

	# TODO: Yas, eliminate all below
	# Keep only warning switches supported by GCC; do not copy Clang-only -Wno-* switches.
	-fno-strict-aliasing
	-Wno-sequence-point
	-Wno-padded
	-Wno-switch-enum
	-Wno-unused-parameter
	-Wno-unused-but-set-parameter
	-Wno-error=unused-function
	-Wno-error=unused-variable
	-Wno-error=unused-parameter
	-Wno-error=ignored-attributes
)

if(LANG STREQUAL "CXX")
	# C++ only, GCC rejects/warns about these when compiling C
	NBL_REQUEST_COMPILE_OPTION_SUPPORT(LANG ${LANG} COMPILE_OPTIONS
		# GCC's counterparts of Clang's -Xclang=-fconstexpr-steps / -ftemplate-depth / -ftemplate-backtrace-limit,
		# the remaining Clang options (macro/spell-checking/caret diagnostic limits) have no GCC equivalent
		-fconstexpr-ops-limit=696969 # https://gcc.gnu.org/onlinedocs/gcc/C_002b_002b-Dialect-Options.html
		-fconstexpr-depth=696969 # https://gcc.gnu.org/onlinedocs/gcc/C_002b_002b-Dialect-Options.html
		-ftemplate-depth=696969 # https://gcc.gnu.org/onlinedocs/gcc/C_002b_002b-Dialect-Options.html
		-ftemplate-backtrace-limit=0 # no limit, https://gcc.gnu.org/onlinedocs/gcc/Diagnostic-Message-Formatting-Options.html
	)
endif()

if(NBL_REQUEST_SSE_4_2)
	NBL_REQUEST_COMPILE_OPTION_SUPPORT(LANG ${LANG} COMPILE_OPTIONS
		-msse4.2 # https://gcc.gnu.org/onlinedocs/gcc/x86-Options.html
) # TODO: (****) optional but then adjust 3rdparty options on fail
endif()

if(NBL_REQUEST_SSE_AVX2)
	NBL_REQUEST_COMPILE_OPTION_SUPPORT(LANG ${LANG} COMPILE_OPTIONS
		-mavx2 # https://gcc.gnu.org/onlinedocs/gcc/x86-Options.html
) # TODO: (****)
endif()

if(NBL_SANITIZE_ADDRESS)
	NBL_REQUEST_COMPILE_OPTION_SUPPORT(LANG ${LANG} COMPILE_OPTIONS -fsanitize=address LINK_OPTIONS -fsanitize=address)
endif()

if(NBL_SANITIZE_THREAD)
	NBL_REQUEST_COMPILE_OPTION_SUPPORT(LANG ${LANG} COMPILE_OPTIONS -fsanitize=thread LINK_OPTIONS -fsanitize=thread)
endif()

NBL_REQUEST_COMPILE_OPTION_SUPPORT(LANG ${LANG} CONFIG DEBUG COMPILE_OPTIONS
	-g # https://gcc.gnu.org/onlinedocs/gcc/Debugging-Options.html
	-Wall # https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html
	-fno-inline-functions # https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html
)

NBL_REQUEST_COMPILE_OPTION_SUPPORT(LANG ${LANG} CONFIG RELEASE COMPILE_OPTIONS
	-O2 # https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html
	-finline-functions # https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html
	-DNDEBUG
)

NBL_REQUEST_COMPILE_OPTION_SUPPORT(LANG ${LANG} CONFIG RELWITHDEBINFO COMPILE_OPTIONS
	-g # https://gcc.gnu.org/onlinedocs/gcc/Debugging-Options.html
	-O1 # https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html
	-finline-functions # https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html
	-DNDEBUG
)
