
import CVulkan

public class ImageView {
    public let pointer: VkImageView
    public let device: Device

    private var image: Image

    init(pointer: VkImageView,
         device: Device,
         image: Image) {
        self.pointer = pointer
        self.device = device
        self.image = image
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

        return ImageView(pointer: imageView!, device: dev, image: createInfo.image)
    }

    deinit {
        print("Destroying image view")
        vkDestroyImageView(self.device.pointer, self.pointer, nil)
    }
}