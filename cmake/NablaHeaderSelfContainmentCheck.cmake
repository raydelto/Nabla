# Opt-in check that every public header compiles on its own, without the precompiled header.
# Enabled with -DNBL_HEADER_SELF_CONTAINMENT_CHECK=ON, then build the `nbl_header_self_containment_check` target.
# It is not part of `all`, so the default build time is unchanged.

# Headers which are not meant to be included on their own, relative to `include/`
set(NBL_HEADER_SELF_CONTAINMENT_EXCLUDES
	# fragments pasted into function bodies by `nbl/asset/format/EFormat.h`
	nbl/asset/format/impl/EFormat_getBitsPerChannel.h
	nbl/asset/format/impl/EFormat_getBlockDimensions.h
	nbl/asset/format/impl/EFormat_getFormatChannelCount.h
	nbl/asset/format/impl/EFormat_getFormatClass.h
	nbl/asset/format/impl/EFormat_getFormatClassBlockBytesize.h
	nbl/asset/format/impl/EFormat_getTexelOrBlockBytesize.h
	# platform implementation included at the end of `nbl/system/IFileViewAllocator.h`
	nbl/system/CFileViewVirtualAllocatorPOSIX.h
	nbl/system/CFileViewVirtualAllocatorWin32.h
	# need `_NABLA_DLL_NAME_`, which only application targets define
	nbl/system/RuntimeModuleLookup.h
	nbl/system/IApplicationFramework.h
	nbl/system/CApplicationAndroid.h
	# need the CUDA SDK (`NBL_COMPILE_WITH_CUDA`)
	nbl/video/CCUDAExportableMemory.h
	nbl/video/CCUDAImportedMemory.h
	nbl/video/CCUDAImportedSemaphore.h
	nbl/video/CUDAInteropNativeAPI.h
	# stale code that does not compile and is not used by Nabla
	nbl/asset/ICPUFramebuffer.h # overrides `IAsset` virtuals that no longer exist
	nbl/asset/material_compiler/CMaterialCompilerGLSLBackendCommon.h # legacy material compiler
	nbl/asset/material_compiler/IFrontend.h
	nbl/asset/material_compiler/IR.h
	nbl/asset/material_compiler2/IR.h
	nbl/asset/metadata/CGLTFMetadata.h # includes the removed `IRenderpassIndependentPipelineMetadata.h`
	nbl/asset/metadata/CGLTFPipelineMetadata.h
	nbl/video/alloc/SimpleGPUBufferAllocator.h # includes the removed `GPUMemoryAllocatorBase.h`
)

# One TU per header under `include/nbl/{core,system,asset,video,ui}`, compiled with the flags of `_TARGET`
function(nbl_add_header_self_containment_check _TARGET)
	set(_ROOT "${NBL_ROOT_PATH}/include")
	file(GLOB_RECURSE _HEADERS RELATIVE "${_ROOT}" CONFIGURE_DEPENDS
		"${_ROOT}/nbl/core/*.h"
		"${_ROOT}/nbl/system/*.h"
		"${_ROOT}/nbl/asset/*.h"
		"${_ROOT}/nbl/video/*.h"
		"${_ROOT}/nbl/ui/*.h"
	)
	list(REMOVE_ITEM _HEADERS ${NBL_HEADER_SELF_CONTAINMENT_EXCLUDES})

	set(_OUT "${CMAKE_CURRENT_BINARY_DIR}/header_self_containment")
	set(_SOURCES)
	foreach(_HEADER IN LISTS _HEADERS)
		string(MAKE_C_IDENTIFIER "${_HEADER}" _NAME)
		set(_SOURCE "${_OUT}/${_NAME}.cpp")
		# only rewritten when the content changes, so reconfiguring doesn't recompile everything
		file(CONFIGURE OUTPUT "${_SOURCE}" CONTENT "#include \"${_HEADER}\"\n" @ONLY)
		list(APPEND _SOURCES "${_SOURCE}")
	endforeach()

	set(_CHECK nbl_header_self_containment_check)
	add_library(${_CHECK} OBJECT EXCLUDE_FROM_ALL ${_SOURCES})
	# same view of the headers as a source file of `_TARGET`, but never its precompiled header
	target_include_directories(${_CHECK} PRIVATE $<TARGET_PROPERTY:${_TARGET},INCLUDE_DIRECTORIES>)
	target_compile_definitions(${_CHECK} PRIVATE $<TARGET_PROPERTY:${_TARGET},COMPILE_DEFINITIONS>)
	target_compile_options(${_CHECK} PRIVATE $<TARGET_PROPERTY:${_TARGET},COMPILE_OPTIONS>)
	target_link_libraries(${_CHECK} PRIVATE $<TARGET_PROPERTY:${_TARGET},LINK_LIBRARIES>)
	set_target_properties(${_CHECK} PROPERTIES DISABLE_PRECOMPILE_HEADERS ON)
	# generated headers (build config, device traits, builtin archives) must exist first
	add_dependencies(${_CHECK} ${_TARGET})

	list(LENGTH _SOURCES _COUNT)
	message(STATUS "Header self-containment check: ${_COUNT} headers, build the `${_CHECK}` target")
endfunction()
