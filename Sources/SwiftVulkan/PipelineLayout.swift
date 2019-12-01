
import CVulkan

public class PipelineLayout {
    public var vulkanPointer: VkPipelineLayout
    public var device: Device

    init(vulkanPointer: VkPipelineLayout,
            device: Device) {
        self.vulkanPointer = vulkanPointer
        self.device = device
    }

    public class func create(device: Device, createInfo: PipelineLayoutCreateInfo) throws -> PipelineLayout {
        var pipelineLayout = VkPipelineLayout(bitPattern: 0)

        let layouts: [VkDescriptorSetLayout?] = createInfo.setLayouts.map { $0.vulkanPointer }
        let pushConstantRanges = createInfo.pushConstantRanges.map { $0.vulkanPointer }

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

        return PipelineLayout(vulkanPointer: pipelineLayout!, device: device)
    }

    deinit {
        vkDestroyPipelineLayout(self.device.pointer, self.vulkanPointer, nil)
    }
}