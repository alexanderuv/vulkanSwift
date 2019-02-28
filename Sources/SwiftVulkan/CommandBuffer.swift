//
// Created by Alexander Ubillus on 2019-02-28.
//

import CVulkan

public class CommandBufferAllocateInfo {

    public let commandPool: CommandPool
    public let level: CommandBufferLevel
    public let commandBufferCount: UInt32

    public init(commandPool: CommandPool,
                level: CommandBufferLevel,
                commandBufferCount: UInt32) {
        self.commandPool = commandPool
        self.level = level
        self.commandBufferCount = commandBufferCount
    }

    func toVulkan() -> VkCommandBufferAllocateInfo {
        return VkCommandBufferAllocateInfo(
                sType: VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
                pNext: nil,
                commandPool: self.commandPool.pointer,
                level: VkCommandBufferLevel(rawValue: self.level.rawValue),
                commandBufferCount: self.commandBufferCount
        )
    }
}

public class CommandBuffer {

    public let pointer: VkCommandBuffer

    init(pointer: VkCommandBuffer) {
        self.pointer = pointer
    }

    public class func allocate(device: Device, info: CommandBufferAllocateInfo) throws -> CommandBuffer {
        var output = VkCommandBuffer(bitPattern: 0) // *pOutput = NULL
        var opResult = VK_SUCCESS

        withUnsafePointer(to: info.toVulkan()) { _createInfo in
            let createInfoPtr = _createInfo
            withUnsafeMutablePointer(to: &output) { mut in
                let outputPtr = mut
                opResult = vkAllocateCommandBuffers(device.pointer, createInfoPtr, outputPtr)
            }
        }

        guard opResult == VK_SUCCESS else {
            throw opResult.toResult()
        }

        return CommandBuffer(pointer: output!)
    }
}
