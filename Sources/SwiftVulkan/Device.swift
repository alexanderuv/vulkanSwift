//  
// Copyright (c) Alexander Ubillus. All rights reserved.  
// Licensed under the MIT License. See LICENSE file in the project root for full license information.  
//

import CVulkan

public class Device {

    public let instance: Instance
    public let pointer: VkDevice

    init(instance: Instance,
         device: VkDevice) {
        self.instance = instance
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
        var swapchain = VkSwapchainKHR(bitPattern: 0)

        var opResult = VK_SUCCESS
        var infoArr = [info.toVulkan()]

        var function = vkGetInstanceProcAddr(self.instance.pointer, "vkCreateSwapchainKHR")
        var rightFunction = unsafeBitCast(function, to: PFN_vkCreateSwapchainKHR.self)
        opResult = rightFunction(self.pointer, &infoArr, nil, &swapchain)
        
        if opResult == VK_SUCCESS {
            return Swapchain(device: self, pointer: swapchain!)
        }

        throw opResult.toResult()
    }

    deinit {
        vkDestroyDevice(pointer, nil)
    }
}