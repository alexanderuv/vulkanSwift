//  
// Copyright (c) Alexander Ubillus. All rights reserved.  
// Licensed under the MIT License. See LICENSE file in the project root for full license information.  
//

import CVulkan

public struct ApplicationInfo {
    // not supported for now
    public let next: Any? = nil
    public let applicationName: String
    public let applicationVersion: UInt32
    public let engineName: String
    public let engineVersion: UInt32
    public let apiVersion: UInt32

    public init(applicationName: String, 
        applicationVersion: Version, 
        engineName: String,
        engineVersion: Version,
        apiVersion: Version) {
        self.applicationName = applicationName
        self.applicationVersion = applicationVersion.rawVersion
        self.engineName = engineName
        self.engineVersion = engineVersion.rawVersion
        self.apiVersion = apiVersion.rawVersion
    }
}

public struct CommandBufferAllocateInfo {

    public let commandPool: CommandPool
    public let level: CommandBufferLevel
    public let commandBufferCount: UInt32

    public init(commandPool: CommandPool,
                level: CommandBufferLevel,
                commandBufferCount: UInt32) {
        self.commandPool = commandPool
        self.level = level
        self.commandBufferCount = commandBufferCount
    }

    func toVulkan() -> VkCommandBufferAllocateInfo {
        return VkCommandBufferAllocateInfo(
            sType: VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
            pNext: nil,
            commandPool: self.commandPool.pointer,
            level: VkCommandBufferLevel(rawValue: self.level.rawValue),
            commandBufferCount: self.commandBufferCount
        )
    }
}

public struct CommandPoolCreateInfo {
    public let next: Any? = nil
    public let flags: Flags
    public let queueFamilyIndex: UInt32

    public init(flags: Flags,
                queueFamilyIndex: UInt32) {
        self.flags = flags
        self.queueFamilyIndex = queueFamilyIndex
    }

    public struct Flags: OptionSet {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue 
        }

        public static let none = Flags(rawValue: 0)
        public static let transient = Flags(rawValue: 1 << 0)
        public static let resetCommandBuffer = Flags(rawValue: 1 << 1)
        public static let protected = Flags(rawValue: 1 << 2)
    }

    func toVulkan() -> VkCommandPoolCreateInfo {
        return VkCommandPoolCreateInfo(
            sType: VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
            pNext: nil,
            flags: self.flags.rawValue,
            queueFamilyIndex: self.queueFamilyIndex
        )
    }
}

public struct ComponentMapping {
    public let r: ComponentSwizzle
    public let g: ComponentSwizzle
    public let b: ComponentSwizzle
    public let a: ComponentSwizzle

    public init(r: ComponentSwizzle,
                g: ComponentSwizzle,
                b: ComponentSwizzle,
                a: ComponentSwizzle) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }

    var vulkan: VkComponentMapping {
        return VkComponentMapping(r: self.r.vulkan, 
                                g: self.g.vulkan, 
                                b: self.b.vulkan,
                                a: self.a.vulkan)
    }

}

public struct DeviceCreateInfo {
    public let flags: Flags
    public let queueCreateInfos: [DeviceQueueCreateInfo]
    public let enabledLayers: [String]
    public let enabledExtensions: [String]
    public let enabledFeatures: PhysicalDeviceFeatures?

    public init(flags :Flags,
                queueCreateInfos: [DeviceQueueCreateInfo],
                enabledLayers: [String],
                enabledExtensions: [String],
                enabledFeatures: PhysicalDeviceFeatures?) {
        self.flags = flags
        self.queueCreateInfos = queueCreateInfos
        self.enabledLayers = enabledLayers
        self.enabledExtensions = enabledExtensions
        self.enabledFeatures = enabledFeatures
    }
    
    public struct Flags: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue    
        }

        public static let none = Flags(rawValue: 0)
    }

    func vulkanExec(action: (VkDeviceCreateInfo) -> ()) {

        let queueCreateInfos = self.queueCreateInfos.map { $0.toVulkan() }

        withArrayOfCStrings(self.enabledLayers) { layers in
            withArrayOfCStrings(self.enabledExtensions) { extensions in

                var featureArr = [self.enabledFeatures?.toVulkan()]
                let dc = VkDeviceCreateInfo(
                        sType: VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
                        pNext: nil,
                        flags: UInt32(flags.rawValue),
                        queueCreateInfoCount: UInt32(self.queueCreateInfos.count),
                        pQueueCreateInfos: queueCreateInfos,
                        enabledLayerCount: UInt32(self.enabledLayers.count),
                        ppEnabledLayerNames: layers,
                        enabledExtensionCount: UInt32(self.enabledExtensions.count),
                        ppEnabledExtensionNames: extensions,
                        pEnabledFeatures: UnsafePointer(&featureArr)
                )

                action(dc)
            }
        }
    }
}

public struct DeviceQueueCreateInfo {
    public let flags: Flags
    public let queueFamilyIndex: UInt32
    public let queuePriorities: [Float]
    
    public struct Flags: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let none = Flags(rawValue: 0)
        public static let protectedBit = Flags(rawValue: 1)
    }

    public init(flags: Flags,
                queueFamilyIndex: UInt32,
                queuePriorities: [Float]) {
        self.flags = flags
        self.queueFamilyIndex = queueFamilyIndex
        self.queuePriorities = queuePriorities
    }

    func toVulkan() -> VkDeviceQueueCreateInfo {
        return VkDeviceQueueCreateInfo(
            sType: VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
            pNext: nil,
            flags: UInt32(self.flags.rawValue),
            queueFamilyIndex: self.queueFamilyIndex,
            queueCount: UInt32(self.queuePriorities.count),
            pQueuePriorities: self.queuePriorities
        )
    }
}

public struct ExtensionProperties {
    public let extensionName: String
    public let specVersion: Version

    init(props: VkExtensionProperties) {
        self.extensionName = convertTupleToString(props.extensionName)
        self.specVersion = Version(from: props.specVersion)
    }
}

public struct Extent2D {
    public let width: UInt32
    public let height: UInt32

    public init() {
        self.width = 0
        self.height = 0
    }

    public init(width: UInt32, height: UInt32) {
        self.width = width
        self.height = height
    }

    init(fromVulkan extent: VkExtent2D) {
        self.width = extent.width
        self.height = extent.height
    }

    var vulkan: VkExtent2D {
        return VkExtent2D(width: self.width, height: self.height)
    }
}

public struct Extent3D {
    public let width: UInt32
    public let height: UInt32
    public let depth: UInt32

    var vulkanValue: VkExtent3D {
        return VkExtent3D(width: self.width, height: self.height, depth: self.depth)
    }
}

public struct ImageCreateInfo {
    public let flags: Flags
    public let imageType: ImageType
    public let format: Format
    public let extent: Extent3D
    public let mipLevels: UInt32
    public let arrayLayers: UInt32
    public let samples: SampleCountFlags
    public let tiling: ImageTiling
    public let usage: ImageUsageFlags
    public let sharingMode: SharingMode
    public let queueFamilyIndices: [UInt32]
    public let initialLayout: ImageLayout

    public init(flags: Flags,
                imageType: ImageType,
                format: Format,
                extent: Extent3D,
                mipLevels: UInt32,
                arrayLayers: UInt32,
                samples: SampleCountFlags,
                tiling: ImageTiling,
                usage: ImageUsageFlags,
                sharingMode: SharingMode,
                queueFamilyIndices: [UInt32],
                initialLayout: ImageLayout) {
        self.flags = flags
        self.imageType = imageType
        self.format = format
        self.extent = extent
        self.mipLevels = mipLevels
        self.arrayLayers = arrayLayers
        self.samples = samples
        self.tiling = tiling
        self.usage = usage
        self.sharingMode = sharingMode
        self.queueFamilyIndices = queueFamilyIndices
        self.initialLayout = initialLayout
    }

    public struct Flags: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue    
        }

        public static let none = Flags(rawValue: 0)
        public static let sparseBinding = Flags(rawValue: 1 << 0)
        public static let sparseResidency = Flags(rawValue: 1 << 1)
        public static let sparseAliased = Flags(rawValue: 1 << 2)
        public static let mutableFormat = Flags(rawValue: 1 << 3)
        public static let cubeCompatible = Flags(rawValue: 1 << 4)
        public static let alias = Flags(rawValue: 0x00000400)
        public static let splitInstanceBindRegions = Flags(rawValue: 0x00000040)
        public static let _2dArrayCompatible = Flags(rawValue: 0x00000020)
        public static let blockTexelViewCompatible = Flags(rawValue: 0x00000080)
        public static let extendedUsage = Flags(rawValue: 0x00000100)
        public static let protected = Flags(rawValue: 0x00000800)
        public static let disjoint = Flags(rawValue: 0x00000200)
        public static let cornerSampled = Flags(rawValue: 0x00002000)
        public static let sampleLocationsCompatibleDepth = Flags(rawValue: 0x00001000)
        public static let subsampled = Flags(rawValue: 0x00004000)

        var vulkan: VkImageCreateFlags {
            return VkImageCreateFlags(rawValue)
        }
    }

    var vulkan: VkImageCreateInfo {
        return VkImageCreateInfo(
            sType: VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO, 
            pNext: nil, 
            flags: self.flags.vulkan,
            imageType: self.imageType.vulkan,
            format: self.format.vulkan,
            extent: self.extent.vulkanValue,
            mipLevels: self.mipLevels,
            arrayLayers: self.arrayLayers,
            samples: self.samples.vulkan,
            tiling: self.tiling.vulkan,
            usage: self.usage.vulkan.rawValue,
            sharingMode: self.sharingMode.vulkan,
            queueFamilyIndexCount: UInt32(self.queueFamilyIndices.count),
            pQueueFamilyIndices: self.queueFamilyIndices,
            initialLayout: self.initialLayout.vulkan)
    }
}

public struct ImageViewCreateInfo {

    public let flags: Flags
    public let image: Image
    public let viewType: ImageViewType
    public let format: Format
    public let components: ComponentMapping
    public let subresourceRange: ImageSubresourceRange

    public init(flags: Flags,
                image: Image,
                viewType: ImageViewType,
                format: Format,
                components: ComponentMapping,
                subresourceRange: ImageSubresourceRange) {
        self.flags = flags
        self.image = image
        self.viewType = viewType
        self.format = format
        self.components = components
        self.subresourceRange = subresourceRange
    }

    public struct Flags: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue    
        }

        public static let none = Flags(rawValue: 0)
        public static let fragmentDensityMapDynamic = Flags(rawValue: 1)

        var vulkan: VkImageViewCreateFlags {
            return VkImageViewCreateFlags(rawValue)
        }
    }

    func toVulkan() -> VkImageViewCreateInfo {
        return VkImageViewCreateInfo(
            sType: VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO, 
            pNext: nil, 
            flags: self.flags.vulkan,
            image: self.image.pointer,
            viewType: self.viewType.vulkan,
            format: self.format.vulkan,
            components: self.components.vulkan,
            subresourceRange: self.subresourceRange.vulkan)
    }
}

public struct ImageSubresourceRange {
    public let aspectMask: ImageAspectFlags
    public let baseMipLevel: UInt32
    public let levelCount: UInt32
    public let baseArrayLayer: UInt32
    public let layerCount: UInt32

    public init(aspectMask: ImageAspectFlags,
                baseMipLevel: UInt32,
                levelCount: UInt32,
                baseArrayLayer: UInt32,
                layerCount: UInt32) {
        self.aspectMask = aspectMask
        self.baseMipLevel = baseMipLevel
        self.levelCount = levelCount
        self.baseArrayLayer = baseArrayLayer
        self.layerCount = layerCount
    }

    var vulkan: VkImageSubresourceRange {
        return VkImageSubresourceRange(
            aspectMask: self.aspectMask.vulkan, 
            baseMipLevel: self.baseMipLevel, 
            levelCount: self.levelCount,
            baseArrayLayer: self.baseArrayLayer,
            layerCount: self.layerCount)
    }
}

public struct InstanceCreateInfo {
    public let next: Any? = nil
    public let flags = 0
    public let applicationInfo: ApplicationInfo?
    public let enabledLayerNames: [String]
    public let enabledExtensionNames: [String]

    public init(applicationInfo: ApplicationInfo?,
        enabledLayerNames: [String],
        enabledExtensionNames: [String]) {
        self.applicationInfo = applicationInfo
        self.enabledLayerNames = enabledLayerNames
        self.enabledExtensionNames = enabledExtensionNames
    }
}

public struct LayerProperties {
    let layerName: String
    let specVersion: UInt32
    let implementationVersion: UInt32
    let description: String

    init(layerName: String,
        specVersion: Version,
        implementationVersion: Version,
        description: String) {
        self.layerName = layerName
        self.specVersion = specVersion.rawVersion
        self.implementationVersion = implementationVersion.rawVersion
        self.description = description
    }
}

public struct PhysicalDeviceFeatures {
    let robustBufferAccess: Bool
    let fullDrawIndexUint32: Bool
    let imageCubeArray: Bool
    let independentBlend: Bool
    let geometryShader: Bool
    let tessellationShader: Bool
    let sampleRateShading: Bool
    let dualSrcBlend: Bool
    let logicOp: Bool
    let multiDrawIndirect: Bool
    let drawIndirectFirstInstance: Bool
    let depthClamp: Bool
    let depthBiasClamp: Bool
    let fillModeNonSolid: Bool
    let depthBounds: Bool
    let wideLines: Bool
    let largePoints: Bool
    let alphaToOne: Bool
    let multiViewport: Bool
    let samplerAnisotropy: Bool
    let textureCompressionETC2: Bool
    let textureCompressionASTC_LDR: Bool
    let textureCompressionBC: Bool
    let occlusionQueryPrecise: Bool
    let pipelineStatisticsQuery: Bool
    let vertexPipelineStoresAndAtomics: Bool
    let fragmentStoresAndAtomics: Bool
    let shaderTessellationAndGeometryPointSize: Bool
    let shaderImageGatherExtended: Bool
    let shaderStorageImageExtendedFormats: Bool
    let shaderStorageImageMultisample: Bool
    let shaderStorageImageReadWithoutFormat: Bool
    let shaderStorageImageWriteWithoutFormat: Bool
    let shaderUniformBufferArrayDynamicIndexing: Bool
    let shaderSampledImageArrayDynamicIndexing: Bool
    let shaderStorageBufferArrayDynamicIndexing: Bool
    let shaderStorageImageArrayDynamicIndexing: Bool
    let shaderClipDistance: Bool
    let shaderCullDistance: Bool
    let shaderFloat64: Bool
    let shaderInt64: Bool
    let shaderInt16: Bool
    let shaderResourceResidency: Bool
    let shaderResourceMinLod: Bool
    let sparseBinding: Bool
    let sparseResidencyBuffer: Bool
    let sparseResidencyImage2D: Bool
    let sparseResidencyImage3D: Bool
    let sparseResidency2Samples: Bool
    let sparseResidency4Samples: Bool
    let sparseResidency8Samples: Bool
    let sparseResidency16Samples: Bool
    let sparseResidencyAliased: Bool
    let variableMultisampleRate: Bool
    let inheritedQueries: Bool

    init(vkFeatures: VkPhysicalDeviceFeatures) {
        self.robustBufferAccess = vkFeatures.robustBufferAccess.toBool()
        self.fullDrawIndexUint32 = vkFeatures.fullDrawIndexUint32.toBool()
        self.imageCubeArray = vkFeatures.imageCubeArray.toBool()
        self.independentBlend = vkFeatures.independentBlend.toBool()
        self.geometryShader = vkFeatures.geometryShader.toBool()
        self.tessellationShader = vkFeatures.tessellationShader.toBool()
        self.sampleRateShading = vkFeatures.sampleRateShading.toBool()
        self.dualSrcBlend = vkFeatures.dualSrcBlend.toBool()
        self.logicOp = vkFeatures.logicOp.toBool()
        self.multiDrawIndirect = vkFeatures.multiDrawIndirect.toBool()
        self.drawIndirectFirstInstance = vkFeatures.drawIndirectFirstInstance.toBool()
        self.depthClamp = vkFeatures.depthClamp.toBool()
        self.depthBiasClamp = vkFeatures.depthBiasClamp.toBool()
        self.fillModeNonSolid = vkFeatures.fillModeNonSolid.toBool()
        self.depthBounds = vkFeatures.depthBounds.toBool()
        self.wideLines = vkFeatures.wideLines.toBool()
        self.largePoints = vkFeatures.largePoints.toBool()
        self.alphaToOne = vkFeatures.alphaToOne.toBool()
        self.multiViewport = vkFeatures.multiViewport.toBool()
        self.samplerAnisotropy = vkFeatures.samplerAnisotropy.toBool()
        self.textureCompressionETC2 = vkFeatures.textureCompressionETC2.toBool()
        self.textureCompressionASTC_LDR = vkFeatures.textureCompressionASTC_LDR.toBool()
        self.textureCompressionBC = vkFeatures.textureCompressionBC.toBool()
        self.occlusionQueryPrecise = vkFeatures.occlusionQueryPrecise.toBool()
        self.pipelineStatisticsQuery = vkFeatures.pipelineStatisticsQuery.toBool()
        self.vertexPipelineStoresAndAtomics = vkFeatures.vertexPipelineStoresAndAtomics.toBool()
        self.fragmentStoresAndAtomics = vkFeatures.fragmentStoresAndAtomics.toBool()
        self.shaderTessellationAndGeometryPointSize = vkFeatures.shaderTessellationAndGeometryPointSize.toBool()
        self.shaderImageGatherExtended = vkFeatures.shaderImageGatherExtended.toBool()
        self.shaderStorageImageExtendedFormats = vkFeatures.shaderStorageImageExtendedFormats.toBool()
        self.shaderStorageImageMultisample = vkFeatures.shaderStorageImageMultisample.toBool()
        self.shaderStorageImageReadWithoutFormat = vkFeatures.shaderStorageImageReadWithoutFormat.toBool()
        self.shaderStorageImageWriteWithoutFormat = vkFeatures.shaderStorageImageWriteWithoutFormat.toBool()
        self.shaderUniformBufferArrayDynamicIndexing = vkFeatures.shaderUniformBufferArrayDynamicIndexing.toBool()
        self.shaderSampledImageArrayDynamicIndexing = vkFeatures.shaderSampledImageArrayDynamicIndexing.toBool()
        self.shaderStorageBufferArrayDynamicIndexing = vkFeatures.shaderStorageBufferArrayDynamicIndexing.toBool()
        self.shaderStorageImageArrayDynamicIndexing = vkFeatures.shaderStorageImageArrayDynamicIndexing.toBool()
        self.shaderClipDistance = vkFeatures.shaderClipDistance.toBool()
        self.shaderCullDistance = vkFeatures.shaderCullDistance.toBool()
        self.shaderFloat64 = vkFeatures.shaderFloat64.toBool()
        self.shaderInt64 = vkFeatures.shaderInt64.toBool()
        self.shaderInt16 = vkFeatures.shaderInt16.toBool()
        self.shaderResourceResidency = vkFeatures.shaderResourceResidency.toBool()
        self.shaderResourceMinLod = vkFeatures.shaderResourceMinLod.toBool()
        self.sparseBinding = vkFeatures.sparseBinding.toBool()
        self.sparseResidencyBuffer = vkFeatures.sparseResidencyBuffer.toBool()
        self.sparseResidencyImage2D = vkFeatures.sparseResidencyImage2D.toBool()
        self.sparseResidencyImage3D = vkFeatures.sparseResidencyImage3D.toBool()
        self.sparseResidency2Samples = vkFeatures.sparseResidency2Samples.toBool()
        self.sparseResidency4Samples = vkFeatures.sparseResidency4Samples.toBool()
        self.sparseResidency8Samples = vkFeatures.sparseResidency8Samples.toBool()
        self.sparseResidency16Samples = vkFeatures.sparseResidency16Samples.toBool()
        self.sparseResidencyAliased = vkFeatures.sparseResidencyAliased.toBool()
        self.variableMultisampleRate = vkFeatures.variableMultisampleRate.toBool()
        self.inheritedQueries = vkFeatures.inheritedQueries.toBool()
    }

    func toVulkan() -> VkPhysicalDeviceFeatures {
        return VkPhysicalDeviceFeatures(
            robustBufferAccess: self.robustBufferAccess.toUInt32(),
            fullDrawIndexUint32: self.fullDrawIndexUint32.toUInt32(),
            imageCubeArray: self.imageCubeArray.toUInt32(),
            independentBlend: self.independentBlend.toUInt32(),
            geometryShader: self.geometryShader.toUInt32(),
            tessellationShader: self.tessellationShader.toUInt32(),
            sampleRateShading: self.sampleRateShading.toUInt32(),
            dualSrcBlend: self.dualSrcBlend.toUInt32(),
            logicOp: self.logicOp.toUInt32(),
            multiDrawIndirect: self.multiDrawIndirect.toUInt32(),
            drawIndirectFirstInstance: self.drawIndirectFirstInstance.toUInt32(),
            depthClamp: self.depthClamp.toUInt32(),
            depthBiasClamp: self.depthBiasClamp.toUInt32(),
            fillModeNonSolid: self.fillModeNonSolid.toUInt32(),
            depthBounds: self.depthBounds.toUInt32(),
            wideLines: self.wideLines.toUInt32(),
            largePoints: self.largePoints.toUInt32(),
            alphaToOne: self.alphaToOne.toUInt32(),
            multiViewport: self.multiViewport.toUInt32(),
            samplerAnisotropy: self.samplerAnisotropy.toUInt32(),
            textureCompressionETC2: self.textureCompressionETC2.toUInt32(),
            textureCompressionASTC_LDR: self.textureCompressionASTC_LDR.toUInt32(),
            textureCompressionBC: self.textureCompressionBC.toUInt32(),
            occlusionQueryPrecise: self.occlusionQueryPrecise.toUInt32(),
            pipelineStatisticsQuery: self.pipelineStatisticsQuery.toUInt32(),
            vertexPipelineStoresAndAtomics: self.vertexPipelineStoresAndAtomics.toUInt32(),
            fragmentStoresAndAtomics: self.fragmentStoresAndAtomics.toUInt32(),
            shaderTessellationAndGeometryPointSize: self.shaderTessellationAndGeometryPointSize.toUInt32(),
            shaderImageGatherExtended: self.shaderImageGatherExtended.toUInt32(),
            shaderStorageImageExtendedFormats: self.shaderStorageImageExtendedFormats.toUInt32(),
            shaderStorageImageMultisample: self.shaderStorageImageMultisample.toUInt32(),
            shaderStorageImageReadWithoutFormat: self.shaderStorageImageReadWithoutFormat.toUInt32(),
            shaderStorageImageWriteWithoutFormat: self.shaderStorageImageWriteWithoutFormat.toUInt32(),
            shaderUniformBufferArrayDynamicIndexing: self.shaderUniformBufferArrayDynamicIndexing.toUInt32(),
            shaderSampledImageArrayDynamicIndexing: self.shaderSampledImageArrayDynamicIndexing.toUInt32(),
            shaderStorageBufferArrayDynamicIndexing: self.shaderStorageBufferArrayDynamicIndexing.toUInt32(),
            shaderStorageImageArrayDynamicIndexing: self.shaderStorageImageArrayDynamicIndexing.toUInt32(),
            shaderClipDistance: self.shaderClipDistance.toUInt32(),
            shaderCullDistance: self.shaderCullDistance.toUInt32(),
            shaderFloat64: self.shaderFloat64.toUInt32(),
            shaderInt64: self.shaderInt64.toUInt32(),
            shaderInt16: self.shaderInt16.toUInt32(),
            shaderResourceResidency: self.shaderResourceResidency.toUInt32(),
            shaderResourceMinLod: self.shaderResourceMinLod.toUInt32(),
            sparseBinding: self.sparseBinding.toUInt32(),
            sparseResidencyBuffer: self.sparseResidencyBuffer.toUInt32(),
            sparseResidencyImage2D: self.sparseResidencyImage2D.toUInt32(),
            sparseResidencyImage3D: self.sparseResidencyImage3D.toUInt32(),
            sparseResidency2Samples: self.sparseResidency2Samples.toUInt32(),
            sparseResidency4Samples: self.sparseResidency4Samples.toUInt32(),
            sparseResidency8Samples: self.sparseResidency8Samples.toUInt32(),
            sparseResidency16Samples: self.sparseResidency16Samples.toUInt32(),
            sparseResidencyAliased: self.sparseResidencyAliased.toUInt32(),
            variableMultisampleRate: self.variableMultisampleRate.toUInt32(),
            inheritedQueries: self.inheritedQueries.toUInt32()
        )
    }
}

public struct PhysicalDeviceProperties {
    public let apiVersion: UInt32
    public let driverVersion: UInt32
    public let vendorID: Int
    public let deviceID: Int
    public let deviceType: PhysicalDeviceType
    public let deviceName: String
    public let pipelineCacheUUID: [UInt8]
    let limits: Any? = nil // TODO: add later if needed
    let sparseProperties: Any? = nil // TODO: add later if needed
}

public struct QueueFamilyProperties {
    public let index: UInt32
    public let queueFlags: Flags
    public let queueCount: UInt32
    public let timestampValidBits: UInt32
    public let minImageTransferGranularity: Extent3D

    public init(index: UInt32,
                queueFlags: Flags,
                queueCount: UInt32,
                timestampValidBits: UInt32,
                minImageTransferGranularity: Extent3D) {
        self.index = index
        self.queueFlags = queueFlags
        self.queueCount = queueCount
        self.timestampValidBits = timestampValidBits
        self.minImageTransferGranularity = minImageTransferGranularity
    }

    public struct Flags: OptionSet {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let graphicsBit = Flags(rawValue: 1 << 0)
        public static let computeBit = Flags(rawValue: 1 << 1)
        public static let transferBit = Flags(rawValue: 1 << 2)
        public static let sparseBindingBit = Flags(rawValue: 1 << 3)
        public static let protectedBit = Flags(rawValue: 1 << 4)
    }
}

public struct SurfaceCapabilities {
    public let minImageCount: UInt32
    public let maxImageCount: UInt32
    public let currentExtent: Extent2D
    public let minImageExtent: Extent2D
    public let maxImageExtent: Extent2D
    public let maxImageArrayLayers: UInt32
    public let supportedTransforms: SurfaceTransformFlags
    public let currentTransform: SurfaceTransformFlags
    public let supportedCompositeAlpha: CompositeAlphaFlags
    public let supportedUsageFlags: ImageUsageFlags

    init(fromVulkan capabilities: VkSurfaceCapabilitiesKHR) {
        self.minImageCount = capabilities.minImageCount
        self.maxImageCount = capabilities.maxImageCount
        self.currentExtent = Extent2D(fromVulkan: capabilities.currentExtent)
        self.minImageExtent = Extent2D(fromVulkan: capabilities.minImageExtent)
        self.maxImageExtent = Extent2D(fromVulkan: capabilities.maxImageExtent)
        self.maxImageArrayLayers = capabilities.maxImageArrayLayers
        self.supportedTransforms = SurfaceTransformFlags(rawValue: capabilities.supportedTransforms)
        self.currentTransform = SurfaceTransformFlags(rawValue: capabilities.currentTransform.rawValue)
        self.supportedCompositeAlpha = CompositeAlphaFlags(rawValue: capabilities.supportedCompositeAlpha)
        self.supportedUsageFlags = ImageUsageFlags(rawValue: capabilities.supportedUsageFlags)
    }
}

public struct SurfaceCreateInfo {
    #if os(macOS)
    let sType = VK_STRUCTURE_TYPE_MACOS_SURFACE_CREATE_INFO_MVK
    #elseif os(Linux)
    let sType = VK_STRUCTURE_TYPE_MACOS_SURFACE_CREATE_INFO_MVK // whatever it is for linux
    #endif
    // let next: Any? = nil
    public let flags: Flags
    public let view: UnsafeRawPointer?

    public init(flags: Flags,
                view: UnsafeRawPointer?) {
        self.flags = flags
        self.view = view
    }

    public struct Flags: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue    
        }

        public static let none = Flags(rawValue: 0)
    }

    func toVulkan() -> VkMacOSSurfaceCreateInfoMVK {
        return VkMacOSSurfaceCreateInfoMVK(
            sType: self.sType,
            pNext: nil,
            flags: UInt32(self.flags.rawValue),
            pView: self.view
        )
    }
}

public struct SurfaceFormat {
    public let format: Format
    public let colorSpace: ColorSpace
}

public struct SwapchainCreateInfo {
    public let pNext: UnsafeRawPointer? = nil
    public let flags: Flags
    public let surface: Surface
    public let minImageCount: UInt32
    public let imageFormat: Format
    public let imageColorSpace: ColorSpace
    public let imageExtent: Extent2D
    public let imageArrayLayers: UInt32
    public let imageUsage: ImageUsageFlags
    public let imageSharingMode: SharingMode
    public let queueFamilyIndices: [UInt32]
    public let preTransform: SurfaceTransformFlags
    public let compositeAlpha: CompositeAlphaFlags
    public let presentMode: PresentMode
    public let clipped: Bool
    public let oldSwapchain: Swapchain?

    public init(flags: Flags,
                surface: Surface,
                minImageCount: UInt32,
                imageFormat: Format,
                imageColorSpace: ColorSpace,
                imageExtent: Extent2D,
                imageArrayLayers: UInt32,
                imageUsage: ImageUsageFlags,
                imageSharingMode: SharingMode,
                queueFamilyIndices: [UInt32],
                preTransform: SurfaceTransformFlags,
                compositeAlpha: CompositeAlphaFlags,
                presentMode: PresentMode,
                clipped: Bool,
                oldSwapchain: Swapchain? = nil) {
        self.flags = flags
        self.surface = surface
        self.minImageCount = minImageCount
        self.imageFormat = imageFormat
        self.imageColorSpace = imageColorSpace
        self.imageExtent = imageExtent
        self.imageArrayLayers = imageArrayLayers
        self.imageUsage = imageUsage
        self.imageSharingMode = imageSharingMode
        self.queueFamilyIndices = queueFamilyIndices
        self.preTransform = preTransform
        self.compositeAlpha = compositeAlpha
        self.presentMode = presentMode
        self.clipped = clipped
        self.oldSwapchain = oldSwapchain
    }

    public struct Flags: OptionSet {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue 
        }

        public static let none = Flags(rawValue: 0)
        public static let splitInstanceBindRegions = Flags(rawValue: 1 << 0)
        public static let protected = Flags(rawValue: 1 << 1)
    }

    func toVulkan() -> VkSwapchainCreateInfoKHR {
        return VkSwapchainCreateInfoKHR(
            sType: VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR,
            pNext: self.pNext,
            flags: VkSwapchainCreateFlagsKHR(self.flags.rawValue),
            surface: self.surface.pointer,
            minImageCount: self.minImageCount,
            imageFormat: self.imageFormat.vulkan,
            imageColorSpace: self.imageColorSpace.vulkan,
            imageExtent: self.imageExtent.vulkan,
            imageArrayLayers: self.imageArrayLayers,
            imageUsage: self.imageUsage.rawValue,
            imageSharingMode: self.imageSharingMode.vulkan,
            queueFamilyIndexCount: UInt32(self.queueFamilyIndices.count),
            pQueueFamilyIndices: self.queueFamilyIndices,
            preTransform: self.preTransform.vulkan,
            compositeAlpha: self.compositeAlpha.vulkan,
            presentMode: self.presentMode.vulkan,
            clipped: self.clipped.vulkan,
            oldSwapchain: self.oldSwapchain?.pointer
        )
    }
}

// This is not a Vulkan struct, but we're adding it to improve semantics
public struct Version {
    let major: Int
    let minor: Int
    let patch: Int

    var rawVersion: UInt32 {
        let val = (major << 22) | (minor << 12) | patch
        return UInt32(val)
    }

    public init(from rawValue: UInt32) {
        let val: Int = Int(rawValue)
        patch = val & 0xFFF
        minor = (val >> 12) & 0x3FF
        major = val >> 22
    }
}