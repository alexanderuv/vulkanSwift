
import CVulkan

public class DescriptorPoolCreateInfo {
    public var flags: Flags
    public var maxSets: UInt32
    public let poolSizes: [DescriptorPoolSize]

    public init(flags: Flags,
                maxSets: UInt32,
                poolSizes: [DescriptorPoolSize]) {
        self.flags = flags
        self.maxSets = maxSets
        self.poolSizes = poolSizes
    }

    public struct Flags: OptionSet {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let none = Flags(rawValue: 0)
        public static let freeDescriptorSet = Flags(rawValue: 0x00000001)
        public static let updateAfterBind = Flags(rawValue: 0x00000002)
    }
}

public class DescriptorPool {

    public let vulkanValue: VkDescriptorPool
    public let device: Device

    init(vulkanValue: VkDescriptorPool, device: Device) {
        self.vulkanValue = vulkanValue
        self.device = device
    }

    public class func create(device: Device, createInfo: DescriptorPoolCreateInfo) throws -> DescriptorPool {
        var pool = VkDescriptorPool(bitPattern: 0)

        let poolSizes = createInfo.poolSizes.map { $0.vulkanValue }
        let ci = VkDescriptorPoolCreateInfo(
            sType: VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO,
            pNext: nil,
            flags: createInfo.flags.rawValue,
            maxSets: createInfo.maxSets,
            poolSizeCount: UInt32(createInfo.poolSizes.count),
            pPoolSizes: poolSizes
        )

        let opResult = withUnsafePointer(to: ci) {
            return vkCreateDescriptorPool(device.pointer, $0, nil, &pool)
        }
        
        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }

        return DescriptorPool(vulkanValue: pool!, device: device)
    }

    deinit {
        vkDestroyDescriptorPool(device.pointer, self.vulkanValue, nil)
    }
}