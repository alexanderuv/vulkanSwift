
import CVulkan

public class DescriptorSet {

    public let vulkanValue: VkDescriptorSet
    public let device: Device

    init(vulkanValue: VkDescriptorSet,
        device: Device) {
        self.vulkanValue = vulkanValue
        self.device = device
    }
}