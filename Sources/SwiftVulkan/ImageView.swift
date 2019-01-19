
import CVulkan

public class ImageView {
    public let pointer: VkImageView
    public let device: Device

    init(pointer: VkImageView,
         device: Device) {
        self.pointer = pointer
        self.device = device
    }

    deinit {
        print("Destroying image view")
        vkDestroyImageView(self.device.pointer, self.pointer, nil)
    }
}