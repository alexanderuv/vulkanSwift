
import CVulkan

public class DescriptorSetLayout {
    public let vulkanPointer: VkDescriptorSetLayout
    public let device: Device

    init(vulkanPointer: VkDescriptorSetLayout,
         device: Device) {
        self.vulkanPointer = vulkanPointer
        self.device = device
    }

    public class func create(
        device: Device, 
        createInfo: DescriptorSetLayoutCreateInfo) throws -> DescriptorSetLayout {

        var layout = VkDescriptorSetLayout(bitPattern: 0)
        let bindings = createInfo.bindings.map { return VkDescriptorSetLayoutBinding(
                binding: $0.binding,
                descriptorType: $0.descriptorType.vulkanPointer,
                descriptorCount: $0.descriptorCount,
                stageFlags: UInt32($0.stageFlags.rawValue),
                pImmutableSamplers: $0.immutableSamplers?.map { p in p.vulkanValue }
        ) }

        let ci = VkDescriptorSetLayoutCreateInfo(
                sType: VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
                pNext: nil,
                flags: createInfo.flags.rawValue,
                bindingCount: UInt32(createInfo.bindings.count),
                pBindings: UnsafePointer(bindings)
        )

        let opResult: VkResult = withUnsafePointer(to: ci) {
            return vkCreateDescriptorSetLayout(device.pointer, $0, nil, &layout)
        }

        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }

        return DescriptorSetLayout(vulkanValue: layout!, device: device)
    }

    deinit {
        vkDestroyDescriptorSetLayout(device.pointer, self.vulkanValue, nil)
    }
}