
import CVulkan

public class PipelineLayout {
    public var vulkanValue: VkPipelineLayout
    public var device: Device

    init(vulkanValue: VkPipelineLayout,
            device: Device) {
        self.vulkanValue = vulkanValue
        self.device = device
    }

    public class func create(device: Device, createInfo: PipelineLayoutCreateInfo) throws -> PipelineLayout {
        var pipelineLayout = VkPipelineLayout(bitPattern: 0)

        let layouts: [VkDescriptorSetLayout?] = createInfo.setLayouts.map { $0.vulkanValue }
        let pushConstantRanges = createInfo.pushConstantRanges.map { $0.vulkanValue }

        let ci = VkPipelineLayoutCreateInfo(
            sType: VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
            pNext: nil, 
            flags: createInfo.flags.rawValue,
            setLayoutCount: UInt32(createInfo.setLayouts.count),
            pSetLayouts: layouts,
            pushConstantRangeCount: UInt32(createInfo.pushConstantRanges.count),
            pPushConstantRanges: pushConstantRanges
        )

        let opResult = withUnsafePointer(to: ci) {
            return vkCreatePipelineLayout(device.pointer, $0, nil, &pipelineLayout)
        }

        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }

        return PipelineLayout(vulkanValue: pipelineLayout!, device: device)
    }

    deinit {
        vkDestroyPipelineLayout(self.device.pointer, self.vulkanValue, nil)
    }
}