
import CVulkan

public class Queue {
    public let pointer: VkQueue

    init(fromVulkan pointer: VkQueue) {
        self.pointer = pointer
    }

    public class func create(fromDevice device: Device, presentFamilyIndex: UInt32) -> Queue {
        var queueArr = [VkQueue?](repeating: VkQueue(bitPattern: 0), count: 1)
        vkGetDeviceQueue(device.pointer, UInt32(presentFamilyIndex), 0, &queueArr)

        return Queue(fromVulkan: queueArr[0]!)
    }
}