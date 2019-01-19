
import CVulkan

public class Queue {
    public let pointer: VkQueue

    init(fromVulkan pointer: VkQueue) {
        self.pointer = pointer
    }

}