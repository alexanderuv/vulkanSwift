
import CVulkan

public class Buffer {
    public let pointer: VkBuffer
    public let device: Device

    init(pointer: VkBuffer,
        device: Device) {
        self.pointer = pointer
        self.device = device
    }

    public lazy var memoryRequirements: MemoryRequirements = {
        var reqs = [VkMemoryRequirements()]
        vkGetBufferMemoryRequirements(self.device.pointer, self.pointer, &reqs)

        return MemoryRequirements(reqs[0])
    }()

    public class func create(device: Device, createInfo: BufferCreateInfo) throws -> Buffer {

        var buffer = VkBuffer(bitPattern: 0)
        let opResult = withUnsafePointer(to: createInfo.vulkan) {
            return vkCreateBuffer(device.pointer, $0, nil, &buffer)
        }
        
        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }

        return Buffer(pointer: buffer!, device: device)
    }

    deinit {
        vkDestroyBuffer(self.device.pointer, self.pointer, nil)
    }
}