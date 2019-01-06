import CVulkan

public struct DeviceQueueCreateInfo {
    public let flags: Flags
    public let queueFamilyIndex: UInt32
    public let queueCount: UInt32
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
                queueCount: UInt32,
                queuePriorities: [Float]) {
        self.flags = flags
        self.queueFamilyIndex = queueFamilyIndex
        self.queueCount = queueCount
        self.queuePriorities = queuePriorities
    }

    func toVulkan() -> VkDeviceQueueCreateInfo {
        return VkDeviceQueueCreateInfo(
            sType: VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
            pNext: nil,
            flags: UInt32(self.flags.rawValue),
            queueFamilyIndex: self.queueFamilyIndex,
            queueCount: self.queueCount,
            pQueuePriorities: self.queuePriorities
        )
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

    func vulkanExec(action: (VkDeviceCreateInfo) -> Void) {

        if let vulkanFeatures = enabledFeatures?.toVulkan() {
            withUnsafePointer(to: vulkanFeatures) {
                let dc = VkDeviceCreateInfo(
                    sType: VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
                    pNext: nil,
                    flags: UInt32(flags.rawValue),
                    queueCreateInfoCount: UInt32(self.queueCreateInfos.count),
                    pQueueCreateInfos: self.queueCreateInfos.map { $0.toVulkan() },
                    enabledLayerCount: UInt32(self.enabledLayers.count),
                    ppEnabledLayerNames: self.enabledLayers.asCStringArray(),
                    enabledExtensionCount: UInt32(self.enabledExtensions.count),
                    ppEnabledExtensionNames: self.enabledExtensions.asCStringArray(),
                    pEnabledFeatures: $0
                )

                action(dc)
            }
        } else {
            let dc = VkDeviceCreateInfo(
                sType: VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
                pNext: nil,
                flags: UInt32(flags.rawValue),
                queueCreateInfoCount: UInt32(self.queueCreateInfos.count),
                pQueueCreateInfos: self.queueCreateInfos.map { $0.toVulkan() },
                enabledLayerCount: UInt32(self.enabledLayers.count),
                ppEnabledLayerNames: self.enabledLayers.asCStringArray(),
                enabledExtensionCount: UInt32(self.enabledExtensions.count),
                ppEnabledExtensionNames: self.enabledExtensions.asCStringArray(),
                pEnabledFeatures: nil
            )

            action(dc)
        }
    }
}

public class Device {
    init(device: VkDevice) {

    }
}