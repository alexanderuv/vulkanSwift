
import CVulkan

public class Image {
    public let pointer: VkImage
    public let device: Device
    let swapchain: Swapchain?

    init(fromVulkan pointer: VkImage,
        device: Device,
        swapchain: Swapchain?) {
        self.pointer = pointer
        self.device = device
        self.swapchain = swapchain
    }

    public class func create(withInfo createInfo: ImageCreateInfo,
                            device: Device) throws -> Image {

        var image = VkImage(bitPattern: 0)
        let opResult = withUnsafePointer(to: createInfo.vulkan) {
            return vkCreateImage(device.pointer, $0, nil, &image)
        }

        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }
        
        return Image(fromVulkan: image!, device: device, swapchain: nil)
    }

    deinit {
        if swapchain == nil {
            print("Destroying image")
            vkDestroyImage(self.device.pointer, self.pointer, nil)
        }
    }
}