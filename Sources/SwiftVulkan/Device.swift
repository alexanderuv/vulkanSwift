//  
// Copyright (c) Alexander Ubillus. All rights reserved.  
// Licensed under the MIT License. See LICENSE file in the project root for full license information.  
//

import CVulkan

public class Device {

    public let pointer: VkDevice

    init(device: VkDevice) {
        self.pointer = device
    }

    public func createCommandPool(createInfo info: CommandPoolCreateInfo) throws -> CommandPool {
        var cCommandPool = VkCommandPool(bitPattern: 0)
        var opResult = VK_SUCCESS

        withUnsafePointer(to: info.toVulkan()) { 
            opResult = vkCreateCommandPool(pointer, $0, nil, &cCommandPool)
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

    public func createSwapchain(createInfo info: SwapchainCreateInfo) throws -> Swapchain {
        //var swapchain = VkSwapchainKHR(bitPattern: 0)
        var swapchainPtr = UnsafeMutablePointer<VkSwapchainKHR?>.allocate(capacity: 1)
        defer {
            swapchainPtr.deallocate()
        }

        var opResult = VK_SUCCESS
        withUnsafePointer(to: info.toVulkan()) {
            opResult = vkCreateSwapchainKHR(self.pointer, $0, nil, swapchainPtr)
        }
        
        if opResult == VK_SUCCESS {
            return Swapchain(device: self, pointer: swapchainPtr.pointee!)
        }

        throw opResult.toResult()
    }

    deinit {
        vkDestroyDevice(pointer, nil)
    }
}