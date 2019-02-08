
import CVulkan

public class RenderPass {
    public let vulkanValue: VkRenderPass
    public let device: Device

    init(vulkanValue: VkRenderPass, device: Device) {
        self.vulkanValue = vulkanValue
        self.device = device
    }

    public class func create(createInfo: RenderPassCreateInfo, device: Device) throws -> RenderPass {
        var renderPass = VkRenderPass(bitPattern: 0)
        var vulkanCreateInfo = createInfo
        let opResult = withUnsafePointer(to: vulkanCreateInfo.toVulkan()) {
            return vkCreateRenderPass(device.pointer, $0, nil, &renderPass)
        }
        
        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }

        return RenderPass(vulkanValue: renderPass!, device: device)
    }

    deinit {
        vkDestroyRenderPass(device.pointer, self.vulkanValue, nil)
    }
}