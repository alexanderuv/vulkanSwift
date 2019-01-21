
import CVulkan

public class ImageView {
    public let pointer: VkImageView
    public let device: Device

    init(pointer: VkImageView,
         device: Device) {
        self.pointer = pointer
        self.device = device
    }

    public class func create(device dev: Device, 
                            createInfo: ImageViewCreateInfo) throws -> ImageView {
        var imageView = VkImageView(bitPattern: 0)

        let opResult = withUnsafePointer(to: createInfo.vulkan) {
            return vkCreateImageView(dev.pointer, $0, nil, &imageView)
        }

        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }

        return ImageView(pointer: imageView!, device: dev)
    }

    deinit {
        print("Destroying image view")
        vkDestroyImageView(self.device.pointer, self.pointer, nil)
    }
}