import CVulkan

public class PhysicalDevice {
    private let physicalDevicePointer: VkPhysicalDevice

    init(instance: Instance, vulkanDevice: VkPhysicalDevice) {
        self.physicalDevicePointer = vulkanDevice
    }

    public lazy var properties: PhysicalDeviceProperties = {
        let cProps = UnsafeMutablePointer<VkPhysicalDeviceProperties>.allocate(capacity: 1)
        defer {
            cProps.deallocate()
        }

        vkGetPhysicalDeviceProperties(self.physicalDevicePointer, cProps)
        let prop = cProps.pointee

        return PhysicalDeviceProperties(
            apiVersion: prop.apiVersion,
            driverVersion: prop.driverVersion,
            vendorID: Int(prop.vendorID),
            deviceID: Int(prop.deviceID),
            deviceType: PhysicalDeviceType(rawValue: Int(prop.deviceType.rawValue))!,
            deviceName: convertTupleToString(prop.deviceName),
            pipelineCacheUUID: convertTupleToByteArray(prop.pipelineCacheUUID)
        )
    }()

    public lazy var queueFamilyProperties: [QueueFamilyProperties] = {
        let countPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        countPtr.initialize(to: 0)
        defer {
            countPtr.deallocate()
        }
        
        vkGetPhysicalDeviceQueueFamilyProperties(self.physicalDevicePointer, countPtr, nil)
        var count = Int(countPtr.pointee)

        var result: [QueueFamilyProperties] = []
        if count > 0 {
            let cProps = UnsafeMutablePointer<VkQueueFamilyProperties>.allocate(capacity: count)
            defer {
                cProps.deallocate()
            }
            vkGetPhysicalDeviceQueueFamilyProperties(self.physicalDevicePointer, countPtr, cProps)
            count = Int(countPtr.pointee)
          
            for i in 0..<count {
                let cProp = cProps[i]
                let newProp = QueueFamilyProperties(
                    queueFlags: QueueFamilyProperties.Flags(rawValue: cProp.queueFlags),
                    queueCount: cProp.queueCount,
                    timestampValidBits: cProp.timestampValidBits,
                    minImageTransferGranularity: cProp.minImageTransferGranularity.swiftVersion()
                )

                print(newProp)
                result.append(newProp)
            }
        }

        return result
    }()

    public lazy var features: PhysicalDeviceFeatures = {
        let featuresPtr = UnsafeMutablePointer<VkPhysicalDeviceFeatures>.allocate(capacity: 1)
        defer {
            featuresPtr.deallocate()
        }

        vkGetPhysicalDeviceFeatures(self.physicalDevicePointer, featuresPtr)
        let features = featuresPtr.pointee

        return PhysicalDeviceFeatures(
            vkFeatures: features
        )
    }()

    public func getSurfaceFormats(for surface: Surface) -> (Result, [SurfaceFormat]?) {
        let countPtr = UnsafeMutablePointer<UInt32>.allocate(capacity: 1)
        countPtr.initialize(to: 0)
        defer {
            countPtr.deallocate()
        }

        var opResult = VK_SUCCESS
        var returnValue: [SurfaceFormat] = []
        opResult = vkGetPhysicalDeviceSurfaceFormatsKHR(self.physicalDevicePointer, surface.surface, countPtr, nil)
        var count = Int(countPtr.pointee)

        if opResult == VK_SUCCESS && count > 0 {
            let formatsPtr = UnsafeMutablePointer<VkSurfaceFormatKHR>.allocate(capacity: count)
            defer {
                formatsPtr.deallocate()
            }

            opResult = vkGetPhysicalDeviceSurfaceFormatsKHR(self.physicalDevicePointer, surface.surface, countPtr, formatsPtr)
            if opResult == VK_SUCCESS && count > 0 {
                for i in 0..<count {
                    let format = formatsPtr[i]
                    let newFormat = SurfaceFormat(
                        format: Format(rawValue: format.format.rawValue)!,
                        colorSpace: ColorSpace(rawValue: format.colorSpace.rawValue)!
                    )

                    print(newFormat)
                    returnValue.append(newFormat)
                }
            }
        }
        
        return (opResult.toResult(), returnValue)
    }

    public func createDevice(createInfo info: DeviceCreateInfo) -> (Result, Device?) {
        let devicePtr = UnsafeMutablePointer<VkDevice?>.allocate(capacity: 1)
        defer {
            devicePtr.deallocate()
        }

        var opResult = VK_SUCCESS
        info.vulkanExec() {
            withUnsafePointer(to: $0) { deviceCreatePtr in
                opResult = vkCreateDevice(self.physicalDevicePointer, deviceCreatePtr, nil, devicePtr)
            }
        }
        
        if opResult == VK_SUCCESS {
            return (opResult.toResult(), Device(device: devicePtr.pointee!))
        }

        return (opResult.toResult(), nil)
    }
}

public class Surface {

    let instance: Instance
    let surface: VkSurfaceKHR

    public init(instance: Instance, surface: VkSurfaceKHR) {
        self.instance = instance
        self.surface = surface
    }

    deinit {
        vkDestroySurfaceKHR(instance.pointer, surface, nil)
    }
}

public struct SurfaceFormat {
    public let format: Format
    public let colorSpace: ColorSpace
}

public struct QueueFamilyProperties {
    public let queueFlags: Flags
    public let queueCount: UInt32
    public let timestampValidBits: UInt32
    public let minImageTransferGranularity: Extent3D

    public init(queueFlags: Flags,
            queueCount: UInt32,
            timestampValidBits: UInt32,
            minImageTransferGranularity: Extent3D) {
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

        public static let none = Flags(rawValue: 1 << 0)
        public static let graphicsBit = Flags(rawValue: 1 << 1)
        public static let computeBit = Flags(rawValue: 1 << 2)
        public static let transferBit = Flags(rawValue: 1 << 3)
        public static let sparseBindingBit = Flags(rawValue: 1 << 4)
        public static let protectedBit = Flags(rawValue: 1 << 5)
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

extension VkExtent3D {
    func swiftVersion() -> Extent3D {
        return Extent3D(
            width: self.width,
            height: self.height,
            depth: self.depth
        )
    }
}