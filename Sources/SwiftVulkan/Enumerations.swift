
public enum PhysicalDeviceType: Int {
    case other = 0,
        integratedGpu,
        discreteGpu,
        virtualGpu,
        cpu
}

enum VkStructureType: UInt32 {
    case applicationInfo = 0,
    instanceCreateInfo = 1,
    deviceQueueCreateInfo = 2,
    deviceCreateInfo = 3,
    submitInfo = 4,
    memoryAllocateInfo = 5,
    mappedMemoryRange = 6,
    bindSparseInfo = 7,
    fenceCreateInfo = 8,
    semaphoreCreateInfo = 9,
    eventCreateInfo = 10,
    queryPoolCreateInfo = 11,
    bufferCreateInfo = 12,
    bufferViewCreateInfo = 13,
    imageCreateInfo = 14,
    imageViewCreateInfo = 15,
    shaderModuleCreateInfo = 16,
    pipelineCacheCreateInfo = 17,
    pipelineShaderStageCreateInfo = 18,
    pipelineVertexInputStateCreateInfo = 19,
    pipelineInputAssemblyStateCreateInfo = 20,
    pipelineTessellationStateCreateInfo = 21,
    pipelineViewportStateCreateInfo = 22,
    pipelineRasterizationStateCreateInfo = 23,
    pipelineMultisampleStateCreateInfo = 24,
    pipelineDepthStencilStateCreateInfo = 25,
    pipelineColorBlendStateCreateInfo = 26,
    pipelineDynamicStateCreateInfo = 27,
    graphicsPipelineCreateInfo = 28,
    computePipelineCreateInfo = 29,
    pipelineLayoutCreateInfo = 30,
    samplerCreateInfo = 31,
    descriptorSetLayoutCreateInfo = 32,
    descriptorPoolCreateInfo = 33,
    descriptorSetAllocateInfo = 34,
    writeDescriptorSet = 35,
    copyDescriptorSet = 36,
    framebufferCreateInfo = 37,
    renderPassCreateInfo = 38,
    commandPoolCreateInfo = 39,
    commandBufferAllocateInfo = 40,
    commandBufferInheritanceInfo = 41,
    commandBufferBeginInfo = 42,
    renderPassBeginInfo = 43,
    bufferMemoryBarrier = 44,
    imageMemoryBarrier = 45,
    memoryBarrier = 46,
    loaderInstanceCreateInfo = 47,
    loaderDeviceCreateInfo = 48,
    physicalDeviceSubgroupProperties = 1000094000,
    bindBufferMemoryInfo = 1000157000,
    bindImageMemoryInfo = 1000157001,
    physicalDevice_16BITStorageFeatures = 1000083000,
    memoryDedicatedRequirements = 1000127000,
    memoryDedicatedAllocateInfo = 1000127001,
    memoryAllocateFlagsInfo = 1000060000,
    deviceGroupRenderPassBeginInfo = 1000060003,
    deviceGroupCommandBufferBeginInfo = 1000060004,
    deviceGroupSubmitInfo = 1000060005,
    deviceGroupBindSparseInfo = 1000060006,
    bindBufferMemoryDeviceGroupInfo = 1000060013,
    bindImageMemoryDeviceGroupInfo = 1000060014,
    physicalDeviceGroupProperties = 1000070000,
    deviceGroupDeviceCreateInfo = 1000070001,
    bufferMemoryRequirementsInfo_2 = 1000146000,
    imageMemoryRequirementsInfo_2 = 1000146001,
    imageSparseMemoryRequirementsInfo_2 = 1000146002,
    memoryRequirements_2 = 1000146003,
    sparseImageMemoryRequirements_2 = 1000146004,
    physicalDeviceFeatures_2 = 1000059000,
    physicalDeviceProperties_2 = 1000059001,
    formatProperties_2 = 1000059002,
    imageFormatProperties_2 = 1000059003,
    physicalDeviceImageFormatInfo_2 = 1000059004,
    queueFamilyProperties_2 = 1000059005,
    physicalDeviceMemoryProperties_2 = 1000059006,
    sparseImageFormatProperties_2 = 1000059007,
    physicalDeviceSparseImageFormatInfo_2 = 1000059008,
    physicalDevicePointClippingProperties = 1000117000,
    renderPassInputAttachmentAspectCreateInfo = 1000117001,
    imageViewUsageCreateInfo = 1000117002,
    pipelineTessellationDomainOriginStateCreateInfo = 1000117003,
    renderPassMultiviewCreateInfo = 1000053000,
    physicalDeviceMultiviewFeatures = 1000053001,
    physicalDeviceMultiviewProperties = 1000053002,
    physicalDeviceVariablePointerFeatures = 1000120000,
    protectedSubmitInfo = 1000145000,
    physicalDeviceProtectedMemoryFeatures = 1000145001,
    physicalDeviceProtectedMemoryProperties = 1000145002,
    deviceQueueInfo_2 = 1000145003,
    samplerYcbcrConversionCreateInfo = 1000156000,
    samplerYcbcrConversionInfo = 1000156001,
    bindImagePlaneMemoryInfo = 1000156002,
    imagePlaneMemoryRequirementsInfo = 1000156003,
    physicalDeviceSamplerYcbcrConversionFeatures = 1000156004,
    samplerYcbcrConversionImageFormatProperties = 1000156005,
    descriptorUpdateTemplateCreateInfo = 1000085000,
    physicalDeviceExternalImageFormatInfo = 1000071000,
    externalImageFormatProperties = 1000071001,
    physicalDeviceExternalBufferInfo = 1000071002,
    externalBufferProperties = 1000071003,
    physicalDeviceIdProperties = 1000071004,
    externalMemoryBufferCreateInfo = 1000072000,
    externalMemoryImageCreateInfo = 1000072001,
    exportMemoryAllocateInfo = 1000072002,
    physicalDeviceExternalFenceInfo = 1000112000,
    externalFenceProperties = 1000112001,
    exportFenceCreateInfo = 1000113000,
    exportSemaphoreCreateInfo = 1000077000,
    physicalDeviceExternalSemaphoreInfo = 1000076000,
    externalSemaphoreProperties = 1000076001,
    physicalDeviceMaintenance_3Properties = 1000168000,
    descriptorSetLayoutSupport = 1000168001,
    physicalDeviceShaderDrawParameterFeatures = 1000063000,
    swapchainCreateInfoKhr = 1000001000,
    presentInfoKhr = 1000001001,
    deviceGroupPresentCapabilitiesKhr = 1000060007,
    imageSwapchainCreateInfoKhr = 1000060008,
    bindImageMemorySwapchainInfoKhr = 1000060009,
    acquireNextImageInfoKhr = 1000060010,
    deviceGroupPresentInfoKhr = 1000060011,
    deviceGroupSwapchainCreateInfoKhr = 1000060012,
    displayModeCreateInfoKhr = 1000002000,
    displaySurfaceCreateInfoKhr = 1000002001,
    displayPresentInfoKhr = 1000003000,
    xlibSurfaceCreateInfoKhr = 1000004000,
    xcbSurfaceCreateInfoKhr = 1000005000,
    waylandSurfaceCreateInfoKhr = 1000006000,
    androidSurfaceCreateInfoKhr = 1000008000,
    WIN32SurfaceCreateInfoKhr = 1000009000,
    debugReportCallbackCreateInfoExt = 1000011000,
    pipelineRasterizationStateRasterizationOrderAmd = 1000018000,
    debugMarkerObjectNameInfoExt = 1000022000,
    debugMarkerObjectTagInfoExt = 1000022001,
    debugMarkerMarkerInfoExt = 1000022002,
    dedicatedAllocationImageCreateInfoNv = 1000026000,
    dedicatedAllocationBufferCreateInfoNv = 1000026001,
    dedicatedAllocationMemoryAllocateInfoNv = 1000026002,
    physicalDeviceTransformFeedbackFeaturesExt = 1000028000,
    physicalDeviceTransformFeedbackPropertiesExt = 1000028001,
    pipelineRasterizationStateStreamCreateInfoExt = 1000028002,
    textureLodGatherFormatPropertiesAmd = 1000041000,
    physicalDeviceCornerSampledImageFeaturesNv = 1000050000,
    externalMemoryImageCreateInfoNv = 1000056000,
    exportMemoryAllocateInfoNv = 1000056001,
    importMemoryWin32HandleInfoNv = 1000057000,
    exportMemoryWin32HandleInfoNv = 1000057001,
    WIN32KeyedMutexAcquireReleaseInfoNv = 1000058000,
    validationFlagsExt = 1000061000,
    viSurfaceCreateInfoNn = 1000062000,
    imageViewAstcDecodeModeExt = 1000067000,
    physicalDeviceAstcDecodeFeaturesExt = 1000067001,
    importMemoryWin32HandleInfoKhr = 1000073000,
    exportMemoryWin32HandleInfoKhr = 1000073001,
    memoryWin32HandlePropertiesKhr = 1000073002,
    memoryGetWin32HandleInfoKhr = 1000073003,
    importMemoryFdInfoKhr = 1000074000,
    memoryFdPropertiesKhr = 1000074001,
    memoryGetFdInfoKhr = 1000074002,
    WIN32KeyedMutexAcquireReleaseInfoKhr = 1000075000,
    importSemaphoreWin32HandleInfoKhr = 1000078000,
    exportSemaphoreWin32HandleInfoKhr = 1000078001,
    D3D12FenceSubmitInfoKhr = 1000078002,
    semaphoreGetWin32HandleInfoKhr = 1000078003,
    importSemaphoreFdInfoKhr = 1000079000,
    semaphoreGetFdInfoKhr = 1000079001,
    physicalDevicePushDescriptorPropertiesKhr = 1000080000,
    commandBufferInheritanceConditionalRenderingInfoExt = 1000081000,
    physicalDeviceConditionalRenderingFeaturesExt = 1000081001,
    conditionalRenderingBeginInfoExt = 1000081002,
    physicalDeviceFloat16Int8FeaturesKhr = 1000082000,
    presentRegionsKhr = 1000084000,
    objectTableCreateInfoNvx = 1000086000,
    indirectCommandsLayoutCreateInfoNvx = 1000086001,
    cmdProcessCommandsInfoNvx = 1000086002,
    cmdReserveSpaceForCommandsInfoNvx = 1000086003,
    deviceGeneratedCommandsLimitsNvx = 1000086004,
    deviceGeneratedCommandsFeaturesNvx = 1000086005,
    pipelineViewport_WScalingStateCreateInfoNv = 1000087000,
    surfaceCapabilities_2Ext = 1000090000,
    displayPowerInfoExt = 1000091000,
    deviceEventInfoExt = 1000091001,
    displayEventInfoExt = 1000091002,
    swapchainCounterCreateInfoExt = 1000091003,
    presentTimesInfoGoogle = 1000092000,
    physicalDeviceMultiviewPerViewAttributesPropertiesNvx = 1000097000,
    pipelineViewportSwizzleStateCreateInfoNv = 1000098000,
    physicalDeviceDiscardRectanglePropertiesExt = 1000099000,
    pipelineDiscardRectangleStateCreateInfoExt = 1000099001,
    physicalDeviceConservativeRasterizationPropertiesExt = 1000101000,
    pipelineRasterizationConservativeStateCreateInfoExt = 1000101001,
    hdrMetadataExt = 1000105000,
    attachmentDescription_2Khr = 1000109000,
    attachmentReference_2Khr = 1000109001,
    subpassDescription_2Khr = 1000109002,
    subpassDependency_2Khr = 1000109003,
    renderPassCreateInfo_2Khr = 1000109004,
    subpassBeginInfoKhr = 1000109005,
    subpassEndInfoKhr = 1000109006,
    sharedPresentSurfaceCapabilitiesKhr = 1000111000,
    importFenceWin32HandleInfoKhr = 1000114000,
    exportFenceWin32HandleInfoKhr = 1000114001,
    fenceGetWin32HandleInfoKhr = 1000114002,
    importFenceFdInfoKhr = 1000115000,
    fenceGetFdInfoKhr = 1000115001,
    physicalDeviceSurfaceInfo_2Khr = 1000119000,
    surfaceCapabilities_2Khr = 1000119001,
    surfaceFormat_2Khr = 1000119002,
    displayProperties_2Khr = 1000121000,
    displayPlaneProperties_2Khr = 1000121001,
    displayModeProperties_2Khr = 1000121002,
    displayPlaneInfo_2Khr = 1000121003,
    displayPlaneCapabilities_2Khr = 1000121004,
    iosSurfaceCreateInfoMvk = 1000122000,
    macosSurfaceCreateInfoMvk = 1000123000,
    debugUtilsObjectNameInfoExt = 1000128000,
    debugUtilsObjectTagInfoExt = 1000128001,
    debugUtilsLabelExt = 1000128002,
    debugUtilsMessengerCallbackDataExt = 1000128003,
    debugUtilsMessengerCreateInfoExt = 1000128004,
    androidHardwareBufferUsageAndroid = 1000129000,
    androidHardwareBufferPropertiesAndroid = 1000129001,
    androidHardwareBufferFormatPropertiesAndroid = 1000129002,
    importAndroidHardwareBufferInfoAndroid = 1000129003,
    memoryGetAndroidHardwareBufferInfoAndroid = 1000129004,
    externalFormatAndroid = 1000129005,
    physicalDeviceSamplerFilterMinmaxPropertiesExt = 1000130000,
    samplerReductionModeCreateInfoExt = 1000130001,
    physicalDeviceInlineUniformBlockFeaturesExt = 1000138000,
    physicalDeviceInlineUniformBlockPropertiesExt = 1000138001,
    writeDescriptorSetInlineUniformBlockExt = 1000138002,
    descriptorPoolInlineUniformBlockCreateInfoExt = 1000138003,
    sampleLocationsInfoExt = 1000143000,
    renderPassSampleLocationsBeginInfoExt = 1000143001,
    pipelineSampleLocationsStateCreateInfoExt = 1000143002,
    physicalDeviceSampleLocationsPropertiesExt = 1000143003,
    multisamplePropertiesExt = 1000143004,
    imageFormatListCreateInfoKhr = 1000147000,
    physicalDeviceBlendOperationAdvancedFeaturesExt = 1000148000,
    physicalDeviceBlendOperationAdvancedPropertiesExt = 1000148001,
    pipelineColorBlendAdvancedStateCreateInfoExt = 1000148002,
    pipelineCoverageToColorStateCreateInfoNv = 1000149000,
    pipelineCoverageModulationStateCreateInfoNv = 1000152000,
    drmFormatModifierPropertiesListExt = 1000158000,
    drmFormatModifierPropertiesExt = 1000158001,
    physicalDeviceImageDrmFormatModifierInfoExt = 1000158002,
    imageDrmFormatModifierListCreateInfoExt = 1000158003,
    imageDrmFormatModifierExplicitCreateInfoExt = 1000158004,
    imageDrmFormatModifierPropertiesExt = 1000158005,
    validationCacheCreateInfoExt = 1000160000,
    shaderModuleValidationCacheCreateInfoExt = 1000160001,
    descriptorSetLayoutBindingFlagsCreateInfoExt = 1000161000,
    physicalDeviceDescriptorIndexingFeaturesExt = 1000161001,
    physicalDeviceDescriptorIndexingPropertiesExt = 1000161002,
    descriptorSetVariableDescriptorCountAllocateInfoExt = 1000161003,
    descriptorSetVariableDescriptorCountLayoutSupportExt = 1000161004,
    pipelineViewportShadingRateImageStateCreateInfoNv = 1000164000,
    physicalDeviceShadingRateImageFeaturesNv = 1000164001,
    physicalDeviceShadingRateImagePropertiesNv = 1000164002,
    pipelineViewportCoarseSampleOrderStateCreateInfoNv = 1000164005,
    rayTracingPipelineCreateInfoNv = 1000165000,
    accelerationStructureCreateInfoNv = 1000165001,
    geometryNv = 1000165003,
    geometryTrianglesNv = 1000165004,
    geometryAabbNv = 1000165005,
    bindAccelerationStructureMemoryInfoNv = 1000165006,
    writeDescriptorSetAccelerationStructureNv = 1000165007,
    accelerationStructureMemoryRequirementsInfoNv = 1000165008,
    physicalDeviceRayTracingPropertiesNv = 1000165009,
    rayTracingShaderGroupCreateInfoNv = 1000165011,
    accelerationStructureInfoNv = 1000165012,
    physicalDeviceRepresentativeFragmentTestFeaturesNv = 1000166000,
    pipelineRepresentativeFragmentTestStateCreateInfoNv = 1000166001,
    deviceQueueGlobalPriorityCreateInfoExt = 1000174000,
    physicalDevice_8BITStorageFeaturesKhr = 1000177000,
    importMemoryHostPointerInfoExt = 1000178000,
    memoryHostPointerPropertiesExt = 1000178001,
    physicalDeviceExternalMemoryHostPropertiesExt = 1000178002,
    physicalDeviceShaderAtomicInt64FeaturesKhr = 1000180000,
    calibratedTimestampInfoExt = 1000184000,
    physicalDeviceShaderCorePropertiesAmd = 1000185000,
    deviceMemoryOverallocationCreateInfoAmd = 1000189000,
    physicalDeviceVertexAttributeDivisorPropertiesExt = 1000190000,
    pipelineVertexInputDivisorStateCreateInfoExt = 1000190001,
    physicalDeviceVertexAttributeDivisorFeaturesExt = 1000190002,
    physicalDeviceDriverPropertiesKhr = 1000196000,
    physicalDeviceFloatControlsPropertiesKhr = 1000197000,
    physicalDeviceComputeShaderDerivativesFeaturesNv = 1000201000,
    physicalDeviceMeshShaderFeaturesNv = 1000202000,
    physicalDeviceMeshShaderPropertiesNv = 1000202001,
    physicalDeviceFragmentShaderBarycentricFeaturesNv = 1000203000,
    physicalDeviceShaderImageFootprintFeaturesNv = 1000204000,
    pipelineViewportExclusiveScissorStateCreateInfoNv = 1000205000,
    physicalDeviceExclusiveScissorFeaturesNv = 1000205002,
    checkpointDataNv = 1000206000,
    queueFamilyCheckpointPropertiesNv = 1000206001,
    physicalDeviceVulkanMemoryModelFeaturesKhr = 1000211000,
    physicalDevicePciBusInfoPropertiesExt = 1000212000,
    imagepipeSurfaceCreateInfoFuchsia = 1000214000,
    physicalDeviceFragmentDensityMapFeaturesExt = 1000218000,
    physicalDeviceFragmentDensityMapPropertiesExt = 1000218001,
    renderPassFragmentDensityMapCreateInfoExt = 1000218002,
    physicalDeviceScalarBlockLayoutFeaturesExt = 1000221000,
    imageStencilUsageCreateInfoExt = 1000246000
    static let debugReportCreateInfoExt = debugReportCallbackCreateInfoExt
    static let renderPassMultiviewCreateInfoKhr = renderPassMultiviewCreateInfo
    static let physicalDeviceMultiviewFeaturesKhr = physicalDeviceMultiviewFeatures
    static let physicalDeviceMultiviewPropertiesKhr = physicalDeviceMultiviewProperties
    static let physicalDeviceFeatures_2Khr = physicalDeviceFeatures_2
    static let physicalDeviceProperties_2Khr = physicalDeviceProperties_2
    static let formatProperties_2Khr = formatProperties_2
    static let imageFormatProperties_2Khr = imageFormatProperties_2
    static let physicalDeviceImageFormatInfo_2Khr = physicalDeviceImageFormatInfo_2
    static let queueFamilyProperties_2Khr = queueFamilyProperties_2
    static let physicalDeviceMemoryProperties_2Khr = physicalDeviceMemoryProperties_2
    static let sparseImageFormatProperties_2Khr = sparseImageFormatProperties_2
    static let physicalDeviceSparseImageFormatInfo_2Khr = physicalDeviceSparseImageFormatInfo_2
    static let memoryAllocateFlagsInfoKhr = memoryAllocateFlagsInfo
    static let deviceGroupRenderPassBeginInfoKhr = deviceGroupRenderPassBeginInfo
    static let deviceGroupCommandBufferBeginInfoKhr = deviceGroupCommandBufferBeginInfo
    static let deviceGroupSubmitInfoKhr = deviceGroupSubmitInfo
    static let deviceGroupBindSparseInfoKhr = deviceGroupBindSparseInfo
    static let bindBufferMemoryDeviceGroupInfoKhr = bindBufferMemoryDeviceGroupInfo
    static let bindImageMemoryDeviceGroupInfoKhr = bindImageMemoryDeviceGroupInfo
    static let physicalDeviceGroupPropertiesKhr = physicalDeviceGroupProperties
    static let deviceGroupDeviceCreateInfoKhr = deviceGroupDeviceCreateInfo
    static let physicalDeviceExternalImageFormatInfoKhr = physicalDeviceExternalImageFormatInfo
    static let externalImageFormatPropertiesKhr = externalImageFormatProperties
    static let physicalDeviceExternalBufferInfoKhr = physicalDeviceExternalBufferInfo
    static let externalBufferPropertiesKhr = externalBufferProperties
    static let physicalDeviceIdPropertiesKhr = physicalDeviceIdProperties
    static let externalMemoryBufferCreateInfoKhr = externalMemoryBufferCreateInfo
    static let externalMemoryImageCreateInfoKhr = externalMemoryImageCreateInfo
    static let exportMemoryAllocateInfoKhr = exportMemoryAllocateInfo
    static let physicalDeviceExternalSemaphoreInfoKhr = physicalDeviceExternalSemaphoreInfo
    static let externalSemaphorePropertiesKhr = externalSemaphoreProperties
    static let exportSemaphoreCreateInfoKhr = exportSemaphoreCreateInfo
    static let physicalDevice_16BITStorageFeaturesKhr = physicalDevice_16BITStorageFeatures
    static let descriptorUpdateTemplateCreateInfoKhr = descriptorUpdateTemplateCreateInfo
    static let surfaceCapabilities2Ext = surfaceCapabilities_2Ext
    static let physicalDeviceExternalFenceInfoKhr = physicalDeviceExternalFenceInfo
    static let externalFencePropertiesKhr = externalFenceProperties
    static let exportFenceCreateInfoKhr = exportFenceCreateInfo
    static let physicalDevicePointClippingPropertiesKhr = physicalDevicePointClippingProperties
    static let renderPassInputAttachmentAspectCreateInfoKhr = renderPassInputAttachmentAspectCreateInfo
    static let imageViewUsageCreateInfoKhr = imageViewUsageCreateInfo
    static let pipelineTessellationDomainOriginStateCreateInfoKhr = pipelineTessellationDomainOriginStateCreateInfo
    static let physicalDeviceVariablePointerFeaturesKhr = physicalDeviceVariablePointerFeatures
    static let memoryDedicatedRequirementsKhr = memoryDedicatedRequirements
    static let memoryDedicatedAllocateInfoKhr = memoryDedicatedAllocateInfo
    static let bufferMemoryRequirementsInfo_2Khr = bufferMemoryRequirementsInfo_2
    static let imageMemoryRequirementsInfo_2Khr = imageMemoryRequirementsInfo_2
    static let imageSparseMemoryRequirementsInfo_2Khr = imageSparseMemoryRequirementsInfo_2
    static let memoryRequirements_2Khr = memoryRequirements_2
    static let sparseImageMemoryRequirements_2Khr = sparseImageMemoryRequirements_2
    static let samplerYcbcrConversionCreateInfoKhr = samplerYcbcrConversionCreateInfo
    static let samplerYcbcrConversionInfoKhr = samplerYcbcrConversionInfo
    static let bindImagePlaneMemoryInfoKhr = bindImagePlaneMemoryInfo
    static let imagePlaneMemoryRequirementsInfoKhr = imagePlaneMemoryRequirementsInfo
    static let physicalDeviceSamplerYcbcrConversionFeaturesKhr = physicalDeviceSamplerYcbcrConversionFeatures
    static let samplerYcbcrConversionImageFormatPropertiesKhr = samplerYcbcrConversionImageFormatProperties
    static let bindBufferMemoryInfoKhr = bindBufferMemoryInfo
    static let bindImageMemoryInfoKhr = bindImageMemoryInfo
    static let physicalDeviceMaintenance_3PropertiesKhr = physicalDeviceMaintenance_3Properties
    static let descriptorSetLayoutSupportKhr = descriptorSetLayoutSupport
}