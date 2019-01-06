import CVulkan

public class Device {

    let pointer: VkDevice

    init(device: VkDevice) {
        self.pointer = device
    }

    public func createCommandPool(createInfo info: CommandPoolCreateInfo) throws -> CommandPool {
        var cCommandPool = VkCommandPool(bitPattern: 0)
        var opResult = VK_SUCCESS

        withUnsafeMutablePointer(to: &cCommandPool) { cp in
            withUnsafePointer(to: info.toVulkan()) { createInfo in
                opResult = vkCreateCommandPool(pointer, createInfo, nil, cp)
            }
        }

        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }

        return CommandPool(
                device: self,
                pointer: cCommandPool!
            )
    }

    public func allocateCommandBuffer(createInfo info: CommandBufferAllocateInfo) throws -> CommandBuffer {
        var output = VkCommandBuffer(bitPattern: 0) // *pOutput = NULL
        var opResult = VK_SUCCESS

        withUnsafePointer(to: info.toVulkan()) { _createInfo in
            let createInfoPtr = _createInfo
            withUnsafeMutablePointer(to: &output) { mut in
                let outputPtr = mut
                opResult = vkAllocateCommandBuffers(self.pointer, createInfoPtr, outputPtr)
            }
        }

        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }
        
        return CommandBuffer(pointer: output!)
    }

    deinit {
        vkDestroyDevice(pointer, nil)
    }
}