
import CVulkan

public class CommandBuffer {

    let pointer: VkCommandBuffer

    init(pointer: VkCommandBuffer) {
        self.pointer = pointer
    }
}

public class CommandPool {
    private let device: Device
    public let pointer: VkCommandPool

    init(device: Device, pointer: VkCommandPool) {
        self.device = device
        self.pointer = pointer
    }

    deinit {
        vkDestroyCommandPool(device.pointer, pointer, nil)
    }
}