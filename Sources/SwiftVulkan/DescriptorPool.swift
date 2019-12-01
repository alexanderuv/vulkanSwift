
import CVulkan

public class DescriptorPool {

    public let vulkanPointer: VkDescriptorPool
    public let device: Device

    init(vulkanPointer: VkDescriptorPool, device: Device) {
        self.vulkanPointer = vulkanPointer
        self.device = device
    }

    public class func create(device: Device, createInfo: DescriptorPoolCreateInfo) throws -> DescriptorPool {
        var pool = VkDescriptorPool(bitPattern: 0)

//        let poolSizes = createInfo.poolSizes.map { $0.vulkanPointer }
//        let ci = VkDescriptorPoolCreateInfo(
//            sType: VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO,
//            pNext: nil,
//            flags: createInfo.flags.rawValue,
//            maxSets: createInfo.maxSets,
//            poolSizeCount: UInt32(createInfo.poolSizes.count),
//            pPoolSizes: poolSizes
//        )
        
        vkCreateDescriptorPool(device.vulkanPointer, createInfo, nil, &pool)

        let opResult = withUnsafePointer(to: ci) {
            return vkCreateDescriptorPool(device.vulkanPointer, $0, nil, &pool)
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
