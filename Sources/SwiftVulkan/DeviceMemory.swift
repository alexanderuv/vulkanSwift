
import CVulkan

public class DeviceMemory {
    private let device: Device
    public let pointer: VkDeviceMemory

    init(_ pointer: VkDeviceMemory,
        device: Device) {
        self.pointer = pointer
        self.device = device
    }

    deinit {
        vkFreeMemory(device.pointer, self.pointer, nil)
    }
}